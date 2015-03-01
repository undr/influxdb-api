require 'spec_helper'

describe 'continuous_queries', integration: true do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ client.databases('db_name').continuous_queries }

  before do
    client.databases.create('db_name')
    subject.all.each{|q| subject.delete(q['id']) }
  end

  after do
    subject.all.each{|q| subject.delete(q['id']) }
    client.databases.delete('db_name')
  end

  describe '.all' do
    context 'when there are no continuous queries' do
      it 'returns empty array' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some continuous queries', version: '<=0.8.3' do
      let(:continuous_query1){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }
      let(:continuous_query2){ 'select MAX(user) as user_max from cpu group by time(1m) into cpu.1m.user_max' }

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
      let(:continuous_query1){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }
      let(:continuous_query2){ 'select MAX(user) as user_max from cpu group by time(1m) into cpu.1m.user_max' }

      before do
        subject.create(continuous_query1)
        subject.create(continuous_query2)
      end

      it 'returns the list of users' do
        expect(subject.all).to match_array([
          { 'time' => 0, 'id' => 1, 'query' => continuous_query1 },
          { 'time' => 0, 'id' => 2, 'query' => continuous_query2 }
        ])
      end
    end
  end

  describe '.create' do
    let(:continuous_query){ 'select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean' }

    it 'creates a new query', version: '<=0.8.3' do
      subject.create(continuous_query)
      expect(subject.all).to eq([{ 'id' => 1, 'query' => continuous_query }])
    end

    it 'creates a new query', version: '>0.8.3' do
      subject.create(continuous_query)
      expect(subject.all).to eq([{ 'time' => 0, 'id' => 1, 'query' => continuous_query }])
    end

    context 'when there is the same query', version: '<=0.8.3' do
      before{ subject.create(continuous_query) }

      it 'creates one more' do
        subject.create(continuous_query)
        expect(subject.all).to match_array([
          { 'id' => 1, 'query' => continuous_query }, { 'id' => 2, 'query' => continuous_query }
        ])
      end
    end

    context 'when there is the same query', version: '>0.8.3' do
      before{ subject.create(continuous_query) }

      it 'creates one more' do
        subject.create(continuous_query)
        expect(subject.all).to match_array([
          { 'time' => 0, 'id' => 1, 'query' => continuous_query },
          { 'time' => 0, 'id' => 2, 'query' => continuous_query }
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
        expect(subject.all).to eq([])
      end
    end
  end
end
