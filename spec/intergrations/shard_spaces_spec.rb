require 'spec_helper'

describe 'shard_spaces', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }
  let(:shard_space){ {
    'name' => 'default',
    'database' => 'db_name',
    'retentionPolicy' => 'inf',
    'shardDuration' => '7d',
    'regex' => '/.*/',
    'replicationFactor' => 1,
    'split' => 1
  } }

  subject{ client.databases('db_name').shard_spaces }

  before{ client.databases.create('db_name') }
  after{ client.databases.delete('db_name') }

  describe '.all' do
    context 'when database just has been created' do
      it 'returns empty list' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some shard spaces' do
      before{ client.databases('db_name').series.write(:name, v: 1) }

      it 'returns list of shard spaces' do
        expect(subject.all).to eq([shard_space])
      end
    end
  end

  describe '.create' do
    it 'creates shard space' do
      subject.create(shard_space)
      expect(subject.all).to eq([shard_space])
    end

    context 'when there is already the same shard space' do
      before{ subject.create(shard_space) }

      it 'raises error' do
        expect{ subject.create(shard_space) }.to raise_error(
          Influxdb::Api::Client::Errors::BadRequest, '[400] Shard space default exists for db db_name'
        )
      end
    end
  end

  describe '.update' do
    let(:new_attributes){ {
      retentionPolicy: '30d',
      shardDuration: '15d',
      regex: '/.*/',
      replicationFactor: 1,
      split: 1
    } }

    let(:unacceptable_attributes){ {
      retentionPolicy: '30d',
      shardDuration: '15d',
      regex: '/.*/',
      replicationFactor: 1,
      split: 1,
      someuUnacceptableAttribute: 'lalala'
    } }

    before{ subject.create(shard_space) }

    it 'updates attributes of shard space' do
      subject.update('default', new_attributes)
      expect(subject.all).to eq([{
        'name' => 'default',
        'database' => 'db_name',
        'retentionPolicy' => '30d',
        'shardDuration' => '15d',
        'regex' => '/.*/',
        'replicationFactor' => 1,
        'split' => 1
      }])
    end

    context 'when same shard space does not exist' do
      it 'raises error' do
        expect{ subject.update('unexisted_name', new_attributes) }.to raise_error(
          Influxdb::Api::Client::Errors::NotAcceptable, "[406] Can't update a shard space that doesn't exist"
        )
      end
    end

    context 'with unacceptable attributes' do
      it 'updates only valid attributes' do
        subject.update('default', unacceptable_attributes)
        expect(subject.all).to eq([{
          'name' => 'default',
          'database' => 'db_name',
          'retentionPolicy' => '30d',
          'shardDuration' => '15d',
          'regex' => '/.*/',
          'replicationFactor' => 1,
          'split' => 1
        }])
      end
    end
  end

  describe '.delete' do
    context 'when shard space exists' do
      before{ subject.create(shard_space) }

      it 'deletes shard space' do
        expect{ subject.delete('default') }.to change{ subject.all.size }.from(1).to(0)
      end
    end

    context 'when shard space does not exist' do
      it 'does nothing' do
        expect{ subject.delete('unexisted_name') }.not_to change{ subject.all.size }
      end
    end
  end
end
