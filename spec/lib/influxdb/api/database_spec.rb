require 'spec_helper'

describe Influxdb::Api::Namespaces do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Database.new(client, 'dbname') }

  describe '#series' do
    specify{ expect(subject.series).to be_instance_of(Influxdb::Api::Namespaces::Series) }
    specify{ expect(subject.series.client).to eq(client) }
    specify{ expect(subject.series.database_name).to eq('dbname') }
  end

  describe '#users' do
    specify{ expect(subject.users).to be_instance_of(Influxdb::Api::Namespaces::Users) }
    specify{ expect(subject.users.client).to eq(client) }
    specify{ expect(subject.users.database_name).to eq('dbname') }
  end

  describe '#continuous_queries' do
    let(:version){ 'InfluxDB v0.8.3 (git: 023abcdef) (leveldb: 1.8)' }

    before{ expect(client).to receive(:version).and_return(Influxdb::Api::ServerVersion.new(version)) }

    specify{ expect(subject.continuous_queries).to be_instance_of(Influxdb::Api::Namespaces::ContinuousQueries::Api) }
    specify{ expect(subject.continuous_queries.client).to eq(client) }
    specify{ expect(subject.continuous_queries.database_name).to eq('dbname') }

    context 'when Influxdb version is more than 0.8.3' do
      let(:version){ 'InfluxDB v0.8.4 (git: 023abcdef) (leveldb: 1.8)' }

      specify{ expect(subject.continuous_queries).to be_instance_of(Influxdb::Api::Namespaces::ContinuousQueries::Sql) }
      specify{ expect(subject.continuous_queries.client).to eq(client) }
      specify{ expect(subject.continuous_queries.database_name).to eq('dbname') }
    end
  end

  describe '#shard_spaces' do
    before{ expect(client).to receive(:version).and_return(Influxdb::Api::ServerVersion.new(version)) }

    context 'when Influxdb version is less than 0.8.3' do
      let(:version){ 'InfluxDB v0.7.3 (git: 023abcdef) (leveldb: 1.8)' }

      specify do
        expect{ subject.shard_spaces }.to raise_error(
          Influxdb::Api::UnsupportedFeature, "Shard space's API is supported only after 0.7.3 version. Current is 0.7.3"
        )
      end
    end

    context 'when Influxdb version is eaqual or more than 0.8.3' do
      let(:version){ 'InfluxDB v0.8.3 (git: 023abcdef) (leveldb: 1.8)' }

      specify{ expect(subject.shard_spaces).to be_instance_of(Influxdb::Api::Namespaces::ShardSpaces) }
      specify{ expect(subject.shard_spaces.client).to eq(client) }
      specify{ expect(subject.shard_spaces.database_name).to eq('dbname') }
    end
  end
end
