require 'spec_helper'

describe 'databases' do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ client.databases }

  before do
    WebMock.disable_net_connect!(allow_localhost: true)
    subject.all.each{|db| subject.delete(db['name']) }
  end

  after do
    subject.all.each{|db| subject.delete(db['name']) }
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  describe '.all' do
    context 'when there is none database' do
      it 'returns empty array' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some databases' do
      before do
        subject.create('db_name1')
        subject.create('db_name2')
      end

      it 'returns the list of databases' do
        expect(subject.all).to eq([{ 'name' => 'db_name1' }, { 'name' => 'db_name2' }])
      end
    end
  end

  describe '.create' do
    it 'creates a new db with given name' do
      subject.create('db_name')
      expect(subject.all.include?({ 'name' => 'db_name' })).to be_truthy
    end

    context 'when there is db with the same name' do
      before{ subject.create('db_name') }

      it 'raises error' do
        expect{ subject.create('db_name') }.to raise_error(
          Influxdb::Api::Client::Errors::Conflict, '[409] database db_name exists'
        )
      end
    end
  end

  describe '.delete' do
    context 'for unexisted db' do
      it 'returns false' do
        expect(subject.delete('db_name')).to be_falsy
      end
    end

    context 'for existed db' do
      before{ subject.create('db_name') }

      it 'removes db and returns true' do
        expect(subject.delete('db_name')).to be_truthy
      end
    end
  end
end
