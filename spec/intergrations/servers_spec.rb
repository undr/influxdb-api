require 'spec_helper'

describe 'servers', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }
  let(:result){ subject.all }

  subject{ client.servers }

  before{ client.databases.create('db_name') }
  after{ client.databases.delete('db_name') }

  describe '.all' do
    it 'returns list of shards' do
      expect(result).to be_instance_of(Array)
      expect(result[0]).to include(
        'id', 'isLeader', 'isUp', 'leaderRaftConnectString', 'leaderRaftName', 'protobufConnectString',
        'raftConnectionString', 'raftName', 'state', 'stateName'
      )
    end
  end
end
