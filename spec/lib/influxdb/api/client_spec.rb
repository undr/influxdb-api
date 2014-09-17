require 'spec_helper'

describe Influxdb::Api::Client do
  let(:client){ Influxdb::Api::Client.new }

  describe '#perform_request' do
    context 'perform get request without params' do
      before do
        stub_request(:get, 'http://root:root@localhost:8086/path').
          to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })
      end

      subject{ client.perform_request('GET', '/path') }

      specify{ expect(subject.status).to eq(200) }
      specify{ expect(subject.body).to eq({}) }
      specify{ expect(subject.headers).to include('content-type' => 'application/json') }
    end
  end
end
