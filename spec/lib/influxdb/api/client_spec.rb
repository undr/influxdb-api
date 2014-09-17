require 'spec_helper'

describe Influxdb::Api::Client do
  let(:client){ Influxdb::Api::Client.new }

  before{ Influxdb::Api.config = Influxdb::Api::Configuration.new }
  after{ Influxdb::Api.config = Influxdb::Api::Configuration.new }

  describe '#perform_request' do
    let(:pool){ client.send(:connection_pool) }

    context 'perform GET request without params' do
      before do
        stub_request(:get, 'http://root:root@localhost:8086/path').
          to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      subject{ client.perform_request('GET', '/path') }

      specify{ expect(subject.status).to eq(200) }
      specify{ expect(subject.body).to eq({}) }
      specify{ expect(subject.headers).to include('content-type' => 'application/json') }
    end

    context 'perform GET request with params' do
      before do
        stub_request(:get, 'http://root:root@localhost:8086/path?key1=value1').
          to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      subject{ client.perform_request('GET', '/path', key1: 'value1') }

      specify{ expect(subject.status).to eq(200) }
      specify{ expect(subject.body).to eq({}) }
      specify{ expect(subject.headers).to include('content-type' => 'application/json') }
    end

    context 'perform GET request with HTTP error' do
      before do
        stub_request(:get, 'http://root:root@localhost:8086/path').
          to_return(status: 404, body: '', headers: { 'Content-Type' => 'application/json' })
      end

      subject{ client.perform_request('GET', '/path') }

      specify{ expect{ subject }.to raise_error(Influxdb::Api::Client::Errors::NotFound) }
    end

    context 'perform GET request with transport error if connection pool more then retry number' do
      before do
        Influxdb::Api.config.hosts = ['localhost', 'influxdb1.server.com', 'influxdb2.server.com']
        Influxdb::Api.config.retry_on_failure = 2

        stub_request(:get, 'http://root:root@localhost:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
        stub_request(:get, 'http://root:root@influxdb1.server.com:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
        stub_request(:get, 'http://root:root@influxdb2.server.com:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
      end

      subject{ client.perform_request('GET', '/path') }

      specify do
        expect{ subject }.to raise_error(Faraday::Error::ConnectionFailed)
        expect(pool.alive.size).to eq(1)
      end
    end

    context 'perform GET request with transport error if connection pool less then retry number' do
      before do
        Influxdb::Api.config.hosts = ['localhost', 'influxdb1.server.com', 'influxdb2.server.com']
        Influxdb::Api.config.retry_on_failure = 4

        stub_request(:get, 'http://root:root@localhost:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
        stub_request(:get, 'http://root:root@influxdb1.server.com:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
        stub_request(:get, 'http://root:root@influxdb2.server.com:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
      end

      subject{ client.perform_request('GET', '/path') }

      specify do
        expect{ subject }.to raise_error(Faraday::Error::ConnectionFailed)
        expect(pool.alive.size).to eq(0)
      end
    end

    context 'perform GET request with 2 transport errors and success' do
      before do
        Influxdb::Api.config.hosts = ['localhost', 'influxdb1.server.com', 'influxdb2.server.com']
        Influxdb::Api.config.retry_on_failure = 4

        stub_request(:get, 'http://root:root@localhost:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
        stub_request(:get, 'http://root:root@influxdb2.server.com:8086/path').
          to_raise(::Faraday::Error::ConnectionFailed)
        stub_request(:get, 'http://root:root@influxdb1.server.com:8086/path').
          to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      subject{ client.perform_request('GET', '/path') }

      specify{ expect(subject.status).to eq(200) }
      specify{ expect(subject.body).to eq({}) }
      specify{ expect(subject.headers).to include('content-type' => 'application/json') }
      specify{ expect{ subject }.to change{ pool.alive.size }.from(3).to(1) }
    end
  end
end
