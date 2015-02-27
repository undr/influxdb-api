require 'spec_helper'

describe 'users' do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ client.databases('db_name').continuous_queries }

  before(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)
    Influxdb::Api.client.databases.create('db_name')
  end

  after(:all) do
    Influxdb::Api.client.databases.delete('db_name')
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  before{ subject.all.each{|u| subject.delete(u['id']) } }
  after{ subject.all.each{|u| subject.delete(u['id']) } }

  describe '.all' do
    context 'when there are no continuous queries' do
      it 'returns empty array' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some continuous queries' do
      let(:continuous_query1){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }
      let(:continuous_query2){ 'select MAX(user) as user_max from cpu group by time(1m) into cpu.1m.user_max' }

      before do
        subject.create(continuous_query1)
        subject.create(continuous_query2)
      end

      it 'returns the list of users' do
        expect(subject.all).to eq([
          { 'id' => 1, 'query' => continuous_query1 }, { 'id' => 2, 'query' => continuous_query2 }
        ])
      end
    end
  end

  describe '.create' do
    let(:continuous_query){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }

    it 'creates a new query' do
      subject.create(continuous_query)
      expect(subject.all).to eq([{ 'id' => 1, 'query' => continuous_query }])
    end

    context 'when there is the same query' do
      before{ subject.create(continuous_query) }

      it 'creates one more' do
        subject.create(continuous_query)
        expect(subject.all).to eq([
          { 'id' => 1, 'query' => continuous_query }, { 'id' => 2, 'query' => continuous_query }
        ])
      end
    end
  end

  describe '.delete' do
    context 'when query does not exist' do
      it 'returns true' do
        expect(subject.delete(1)).to be_truthy
      end
    end

    context 'when query exists' do
      let(:continuous_query){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }

      before{ subject.create(continuous_query) }

      it 'removes db and returns true' do
        expect(subject.delete(1)).to be_truthy
      end
    end
  end
end
