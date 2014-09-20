require 'spec_helper'

describe Influxdb::Api::Namespaces do
  let(:config){ Influxdb::Api::Configuration.new }

  subject{ Influxdb::Api::Client.new(config) }

  describe '#databases' do
    context 'with argument' do
      specify{ expect(subject.databases('dbname')).to be_instance_of(Influxdb::Api::Database) }
      specify{ expect(subject.databases('dbname').client).to eq(subject) }
      specify{ expect(subject.databases('dbname').name).to eq('dbname') }
    end

    context 'without argument' do
      specify{ expect(subject.databases).to be_instance_of(Influxdb::Api::Namespaces::Databases) }
      specify{ expect(subject.databases.client).to eq(subject) }
    end
  end

  describe '#cluster_admins' do
    specify{ expect(subject.cluster_admins).to be_instance_of(Influxdb::Api::Namespaces::ClusterAdmins) }
    specify{ expect(subject.cluster_admins.client).to eq(subject) }
  end

  describe '#shards' do
    specify{ expect(subject.shards).to be_instance_of(Influxdb::Api::Namespaces::Shards) }
    specify{ expect(subject.shards.client).to eq(subject) }
  end

  describe '#servers' do
    specify{ expect(subject.servers).to be_instance_of(Influxdb::Api::Namespaces::Servers) }
    specify{ expect(subject.servers.client).to eq(subject) }
  end

  describe '#version' do
    let(:version){ 'InfluxDB v0.7.3 (git: 023abcdef) (leveldb: 1.8)' }

    before do
      stub_request(:get, 'http://root:root@localhost:8086/ping').
        to_return(status: 200, body: '{}', headers: { 'X-Influxdb-Version' => version })
    end

    specify{ expect(subject.version).to be_instance_of(Influxdb::Api::ServerVersion) }
    specify{ expect(subject.version.to_s).to eq(version) }
  end

  describe '#sync?' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/sync').
        to_return(status: 200, body: 'true', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.sync?).to be_truthy }
  end

  describe '#interfaces' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/interfaces').
        to_return(status: 200, body: '["default"]', headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.interfaces).to eq(["default"])}
  end
end
