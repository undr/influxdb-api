require 'spec_helper'

describe Influxdb::Api::Namespaces::Databases do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::Databases.new(client) }

  describe '#all' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/db').
        to_return(status: 200, body: '[{"name":"dbname"}]', headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.all).to eq([{ 'name' => 'dbname' }]) }
  end

  describe '#create' do
    before do
      stub_request(:post, 'http://root:root@localhost:8086/db').
        with(body: '{"name":"dbname"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.create('dbname')).to be_truthy }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/db/dbname').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete('dbname')).to be_truthy }
  end
end
