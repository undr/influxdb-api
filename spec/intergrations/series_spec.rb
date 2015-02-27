require 'spec_helper'

describe 'series' do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ client.databases('db_name').series }

  before(:all) do
    WebMock.disable_net_connect!(allow_localhost: true)
    Influxdb::Api.client.databases.create('db_name')
  end

  after(:all) do
    Influxdb::Api.client.databases.delete('db_name')
    WebMock.disable_net_connect!(allow_localhost: false)
  end

  before{ subject.all.each{|name| subject.delete(name) } }
  after{ subject.all.each{|name| subject.delete(name) } }

  def series_data(name)
    name = name.to_s
    subject.execute('select * from ' + name)[name] || []
  end

  describe '.all' do
    context 'when there is none series' do
      it 'returns empty array' do
        expect(subject.all).to eq([])
      end
    end

    context 'when there are some series' do
      before do
        subject.write('name1', v: 1)
        subject.write('name2', v: 2)
      end

      it 'returns the list of series' do
        expect(subject.all).to match_array(['name1', 'name2'])
      end
    end
  end

  describe '.write' do
    it 'writes row into the series' do
      expect{ subject.write(:name, v: 1) }.to change{ series_data(:name).size }.from(0).to(1)
    end

    it 'writes multiple rows into the series' do
      expect{ subject.write(:name, [{ v: 1 }, { v: 2 }]) }.to change{ series_data(:name).size }.from(0).to(2)
    end

    it 'writes multiple rows into multiple series' do
      subject.write(name1: [{ v: 1 }], name2: [{ v: 2 }])

      expect(series_data(:name1).size).to eq(1)
      expect(series_data(:name2).size).to eq(1)
    end
  end

  describe '.execute' do
    context 'when series does not exist' do
      it 'returns empty Hash' do
        expect(subject.execute('SELECT * FROM name')).to eq({})
      end
    end

    context 'when series exists', time_freeze: '16.09.2014 00:00:00 +0700' do
      before{ subject.write(:name, v: 1) }

      let(:result){ subject.execute('SELECT * FROM name') }

      it 'returns result of the query' do
        expect(result).to be_instance_of(Hash)
        expect(result['name']).to be_instance_of(Array)
        expect(result['name'].size).to eq(1)
        expect(result['name'][0]).to be_instance_of(Hash)
        expect(result['name'][0]['v']).to eq(1)
      end
    end
  end

  describe '.delete' do
    context 'for unexisted series' do
      it 'returns true' do
        expect(subject.delete('name')).to be_truthy
      end
    end

    context 'for existed db' do
      before{ subject.write(:name, v: 1) }

      it 'removes db and returns true' do
        expect(subject.delete('name')).to be_truthy
      end
    end
  end
end
