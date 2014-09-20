require 'spec_helper'

describe Influxdb::Api::Namespaces::ShardSpaces do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }
  let(:shard_spaces){ {
    'name' => 'default',
    'database' => 'dbname',
    'retentionPolicy' => 'inf',
    'shardDuration' => '7d',
    'regex' => '/.*/',
    'replicationFactor' => 1,
    'split' => 1
  } }

  subject{ Influxdb::Api::Namespaces::ShardSpaces.new(client, 'dbname') }

  describe '#all' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/cluster/shard_spaces').
        to_return(status: 200, body: MultiJson.dump([shard_spaces]), headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.all).to eq([shard_spaces]) }
  end

  describe '#create' do
    before do
      stub_request(:post, 'http://root:root@localhost:8086/cluster/shard_spaces/dbname').
        with(body: MultiJson.dump(shard_spaces), headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.create(shard_spaces)).to be_truthy }
  end

  describe '#update' do
    before do
      stub_request(:post, 'http://root:root@localhost:8086/cluster/shard_spaces/dbname/default').
        with(body: '{"shardDuration":"1d"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.update('default', shardDuration: '1d')).to be_truthy }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/cluster/shard_spaces/dbname/default').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete('default')).to be_truthy }
  end
end
