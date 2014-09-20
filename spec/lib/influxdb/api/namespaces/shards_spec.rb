require 'spec_helper'

describe Influxdb::Api::Namespaces::Shards do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::Shards.new(client) }

  describe '#all' do
    let(:shards){ {
      'longTerm' => [],
      'shortTerm' => [{
        'endTime' => 1411603200,
        'id'=>2,
        'serverIds' => [1],
        'startTime' => 1410998400
      }]
    } }

    before do
      stub_request(:get, 'http://root:root@localhost:8086/cluster/shards').
        to_return(status: 200, body: MultiJson.dump(shards), headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.all).to eq(shards) }
  end

  describe '#create' do
    let(:shard){ {
      'endTime' => 1411603200,
      'serverIds' => [1],
      'startTime' => 1410998400
    } }

    before do
      stub_request(:post, 'http://root:root@localhost:8086/cluster/shards').
        with(body: MultiJson.dump(shard), headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.create(shard)).to be_truthy }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/cluster/shards/1').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete(1)).to be_truthy }
  end
end
