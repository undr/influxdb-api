require 'spec_helper'

describe 'continuous_queries', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }
  let(:continuous_query1){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }
  let(:continuous_query2){ 'select MAX(user) as user_max from cpu group by time(1m) into cpu.1m.user_max' }
  let(:continuous_query1_088){ 'select MEAN(user) as user_mean from "cpu" group by time(1m) into cpu.1m.user_mean' }
  let(:continuous_query2_088){ 'select MAX(user) as user_max from "cpu" group by time(1m) into cpu.1m.user_max' }

  subject{ client.databases('db_name').continuous_queries }

  before do
    client.databases.create('db_name')
    subject.all.each{|q| subject.delete(q['id']) }
  end

  after{ client.databases.delete('db_name') }

  describe '.all' do
    context 'when there are no continuous queries' do
      it 'returns empty array' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some continuous queries', version: '<=0.8.3' do
      before do
        subject.create(continuous_query1)
        subject.create(continuous_query2)
      end

      it 'returns the list of users' do
        expect(subject.all).to match_array([
          { 'id' => 1, 'query' => continuous_query1 }, { 'id' => 2, 'query' => continuous_query2 }
        ])
      end
    end

    context 'when there are some continuous queries', version: '>0.8.3' do
      before do
        subject.create(continuous_query1)
        subject.create(continuous_query2)
      end

      it 'returns the list of users' do
        expect(subject.all).to match_array([
          { 'time' => 0, 'id' => 1, 'query' => continuous_query1_088 },
          { 'time' => 0, 'id' => 2, 'query' => continuous_query2_088 }
        ])
      end
    end
  end

  describe '.create' do
    it 'creates a new query', version: '<=0.8.3' do
      subject.create(continuous_query1)
      expect(subject.all).to eq([{ 'id' => 1, 'query' => continuous_query1 }])
    end

    it 'creates a new query', version: '>0.8.3' do
      subject.create(continuous_query1)
      expect(subject.all).to eq([{ 'time' => 0, 'id' => 1, 'query' => continuous_query1_088 }])
    end

    context 'when there is the same query', version: '<=0.8.3' do
      before{ subject.create(continuous_query1) }

      it 'creates one more' do
        subject.create(continuous_query1)
        expect(subject.all).to match_array([
          { 'id' => 1, 'query' => continuous_query1 }, { 'id' => 2, 'query' => continuous_query1 }
        ])
      end
    end

    context 'when there is the same query', version: '>0.8.3' do
      before{ subject.create(continuous_query1) }

      it 'creates one more' do
        subject.create(continuous_query1)
        expect(subject.all).to match_array([
          { 'time' => 0, 'id' => 1, 'query' => continuous_query1_088 },
          { 'time' => 0, 'id' => 2, 'query' => continuous_query1_088 }
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
      before{ subject.create(continuous_query1) }

      it 'removes db and returns true' do
        expect(subject.delete(1)).to be_truthy
        expect(subject.all).to eq([])
      end
    end
  end
end
