require 'spec_helper'

describe 'shards', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }
  let(:result){ subject.all }

  subject{ client.shards }

  before do
    client.databases.create('db_name')
    client.databases('db_name').series.write(:name, v: 1)
  end

  after{ client.databases.delete('db_name') }

  describe '.all' do
    it 'returns list of shards', version: '>0.7.3' do
      expect(result).to be_instance_of(Array)
      expect(result).not_to be_empty
    end

    it 'returns list of shards', version: '<=0.7.3' do
      expect(result).to be_instance_of(Hash)
      expect(result).not_to be_empty
    end
  end

  describe '.create', time_freeze: Time.now, version: '<=0.7.3' do
    let(:attributes){ {
      startTime: Time.now,
      endTime: Time.now.to_i + 86400,
      spaceName: 'default',
      shards: [{ serverIds: [1] }],
      database: 'db_name'
    } }

    it 'creates new shard' do
      subject.create(attributes)

      expect(result.size).to eq(2)
      expect(result['shortTerm'][1]['startTime']).to eq(Time.now.to_i)
      expect(result['shortTerm'][1]['endTime']).to eq(Time.now.to_i + 86400)
      expect(result['shortTerm'][1]['spaceName']).to eq('default')
      expect(result['shortTerm'][1]['database']).to eq('db_name')
      expect(result['shortTerm'][1]['serverIds']).to eq([1])
    end
  end

  describe '.create', time_freeze: Time.now, version: '>0.7.3' do
    let(:attributes){ {
      startTime: Time.now,
      endTime: Time.now.to_i + 86400,
      spaceName: 'default',
      shards: [{ serverIds: [1] }],
      database: 'db_name'
    } }

    it 'creates new shard' do
      subject.create(attributes)

      expect(result.size).to eq(2)
      expect(result[1]['startTime']).to eq(Time.now.to_i)
      expect(result[1]['endTime']).to eq(Time.now.to_i + 86400)
      expect(result[1]['spaceName']).to eq('default')
      expect(result[1]['database']).to eq('db_name')
      expect(result[1]['serverIds']).to eq([1])
    end
  end

  describe '.delete' do
    # It doesn't work on InfluxDB before 0.9.0
    # https://github.com/influxdb/influxdb/issues/1043
    skip("It doesn't work on InfluxDB before 0.9.0 (https://github.com/influxdb/influxdb/issues/1043)") do

      let(:shard_id){ result[0]['id'] }

      it 'deletes shard' do
        expect{ subject.delete(shard_id) }.to change{ subject.all.size }.from(1).to(0)
      end
    end
  end
end
