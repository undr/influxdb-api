require 'spec_helper'

describe Influxdb::Api::Namespaces::Users do
  let(:config){ Influxdb::Api::Configuration.new }
  let(:client){ Influxdb::Api::Client.new(config) }

  subject{ Influxdb::Api::Namespaces::Users.new(client, 'dbname') }

  describe '#all' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/users').
        to_return(status: 200, body: '[{"name":"username"}]', headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.all).to eq([{ 'name' => 'username' }]) }
  end

  describe '#find' do
    before do
      stub_request(:get, 'http://root:root@localhost:8086/db/dbname/users/username').
        to_return(status: 200, body: '{"name":"username"}', headers: { 'Content-Type' => 'application/json' })
    end

    specify{ expect(subject.find('username')).to eq('name' => 'username') }
  end

  describe '#create' do
    before do
      stub_request(:post, 'http://root:root@localhost:8086/db/dbname/users').
        with(body: '{"name":"username","password":"pass"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.create(name: 'username', password: 'pass')).to be_truthy }
  end

  describe '#update' do
    before do
      stub_request(:post, 'http://root:root@localhost:8086/db/dbname/users/username').
        with(body: '{"password":"newpass"}', headers: { 'Content-Type' => 'application/json' }).
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.update('username', password: 'newpass')).to be_truthy }
  end

  describe '#delete' do
    before do
      stub_request(:delete, 'http://root:root@localhost:8086/db/dbname/users/username').
        to_return(status: 200, body: '', headers: { 'Content-Type' => 'text/plain' })
    end

    specify{ expect(subject.delete('username')).to be_truthy }
  end
end
