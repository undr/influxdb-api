require 'spec_helper'

describe Influxdb::Api::Namespaces::ContinuousQueries::Sql do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::ContinuousQueries::Sql.new(client, 'dbname') }

  describe '#all' do
    let(:response){ MultiJson.dump([{
      'name' => 'continuous queries',
      'columns' => ['id', 'query'],
      'points' => [[1, 'select type from events into events.[page_id]']]
    }]) }

    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/series?q=LIST%20CONTINUOUS%20QUERIES').
        to_return(status: 200, body: response, headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.all).to eq([{ 'id' => 1, 'query' => 'select type from events into events.[page_id]' }]) }
  end

  describe '#create' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/series?q=select%20type%20from%20events%20into%20events.[page_id]').
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.create('select type from events into events.[page_id]')).to be_truthy }
  end

  describe '#delete' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/series?q=DROP%20CONTINUOUS%20QUERY%201').
        to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.delete(1)).to be_truthy }
  end
end
