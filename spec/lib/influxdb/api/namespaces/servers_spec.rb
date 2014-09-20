require 'spec_helper'

describe Influxdb::Api::Namespaces::Servers do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::Servers.new(client) }

  describe '#all' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/cluster/servers').
        to_return(
          status: 200,
          body: '[{"id":1,"protobufConnectString":"localhost:8099"}]',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    specify{ expect(subject.all).to eq([{ 'id' => 1, 'protobufConnectString' => 'localhost:8099' }]) }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/cluster/servers/1').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete(1)).to be_truthy }
  end
end
