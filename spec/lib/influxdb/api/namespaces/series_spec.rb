require 'spec_helper'

describe Influxdb::Api::Namespaces::Series do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::Series.new(client, 'dbname') }

  describe '#all' do
    let(:response){ MultiJson.dump([{
      "name"=>"cpu",
      "columns"=>["time", "sequence_number"],
      "points"=>[]
    }]) }

    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/series?q=SELECT%20*%20FROM%20/.*/%20LIMIT%201').
        to_return(status: 200, body: response, headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.all).to eq(['cpu']) }
  end

  describe '#write' do
    context 'one series of point' do
      let(:request){ MultiJson.dump([{ name: :cpu, columns: [:value], points: [[1]] }]) }

      before do
        stub_request(:post, 'http://root:root@localhost:8086/db/dbname/series').
          with(body: request, headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
      end

      specify{ expect(subject.write('cpu', value: 1)).to be_truthy }
    end

    context 'one series of points' do
      let(:request){ MultiJson.dump([{ name: :cpu, columns: [:value], points: [[1], [2]] }]) }

      before do
        stub_request(:post, 'http://root:root@localhost:8086/db/dbname/series').
          with(body: request, headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
      end

      specify{ expect(subject.write('cpu', [{ value: 1 }, { value: 2 }])).to be_truthy }
    end

    context 'many series of point' do
      let(:request){ MultiJson.dump([
        { name: :cpu, columns: [:value], points: [[1]] },
        { name: :memory, columns: [:value], points: [[1234567890]] }
      ]) }

      before do
        stub_request(:post, 'http://root:root@localhost:8086/db/dbname/series').
          with(body: request, headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
      end

      specify{ expect(subject.write(cpu: { value: 1 }, memory: { value: 1234567890 })).to be_truthy }
    end

    context 'many series of points' do
      let(:series){ { cpu: [{ value: 1 }, { value: 2 }], memory: [{ value: 1234567890 }, { value: 1234567899 }] } }
      let(:request){ MultiJson.dump([
        { name: :cpu, columns: [:value], points: [[1], [2]] },
        { name: :memory, columns: [:value], points: [[1234567890], [1234567899]] }
      ]) }

      before do
        stub_request(:post, 'http://root:root@localhost:8086/db/dbname/series').
          with(body: request, headers: { 'Content-Type' => 'application/json' }).
          to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
      end

      specify{ expect(subject.write(series)).to be_truthy }
    end
  end

  describe '#execute' do
    let(:response){ [{
      'name' => 'cpu',
      'columns' => ['time', 'sequence_number', 'value'],
      'points' => [[1411215771762, 440001, 1]]
    }] }

    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/series?q=select%20*%20from%20cpu').
        with(headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: MultiJson.dump(response), headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.execute('select * from cpu')).to eq({
      'cpu' => [{ 'time' => 1411215771762, 'sequence_number' => 440001, 'value' => 1 }]
    }) }
  end

  describe '#raw_execute' do
    let(:response){ [{ 'name' => 'cpu', 'columns' => ['time', 'sequence_number'], 'points' => [] }] }

    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/series?q=list%20series').
        with(headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: MultiJson.dump(response), headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.raw_execute('list series')).to eq(response) }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/db/dbname/series/name').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete('name')).to be_truthy }
  end
end
