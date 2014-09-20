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
    specify{ expect(subject.continuous_queries).to be_instance_of(Influxdb::Api::Namespaces::ContinuousQueries) }
    specify{ expect(subject.continuous_queries.client).to eq(client) }
    specify{ expect(subject.continuous_queries.database_name).to eq('dbname') }
  end

  describe '#shard_spaces' do
    specify{ expect(subject.shard_spaces).to be_instance_of(Influxdb::Api::Namespaces::ShardSpaces) }
    specify{ expect(subject.shard_spaces.client).to eq(client) }
    specify{ expect(subject.shard_spaces.database_name).to eq('dbname') }
  end
end
