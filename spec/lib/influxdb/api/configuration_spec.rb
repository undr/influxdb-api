require 'spec_helper'

describe Influxdb::Api::Configuration do
  subject{ Influxdb::Api::Configuration.new }

  describe '#hosts' do
    specify{ expect(subject.hosts).to eq(['http://localhost:8086']) }
  end

  describe '#hosts=' do
    context 'when passed host as string' do
      before{ subject.hosts = 'localhost' }
      specify{ expect(subject.hosts).to eq(['http://localhost:8086']) }
    end

    context 'when passed host and port as string' do
      before{ subject.hosts = 'localhost:9096' }
      specify{ expect(subject.hosts).to eq(['http://localhost:9096']) }
    end

    context 'when passed scheme, host and port' do
      before{ subject.hosts = 'http://localhost:8080' }
      specify{ expect(subject.hosts).to eq(['http://localhost:8080']) }
    end

    context 'when passed scheme, host, port and credentials' do
      before{ subject.hosts = 'http://user:pass@localhost:8080' }
      specify{ expect(subject.hosts).to eq(['http://user:pass@localhost:8080']) }
    end

    context 'when passed host as URI' do
      before{ subject.hosts = URI.parse('http://localhost:8080') }
      specify{ expect(subject.hosts).to eq(['http://localhost:8080']) }
    end

    context 'when passed host as Hash' do
      before{ subject.hosts = { host: 'localhost' } }
      specify{ expect(subject.hosts).to eq(['http://localhost:8086']) }
    end

    context 'when passed host as Hash' do
      before{ subject.hosts = { host: 'localhost', port: '9000' } }
      specify{ expect(subject.hosts).to eq(['http://localhost:9000']) }
    end
  end

  describe '#selector' do
    specify{ expect(subject.selector).to be_instance_of(Influxdb::Api::Client::Selector::RoundRobin) }
  end

  describe '#serializer' do
    specify{ expect(subject.serializer).to eq(::MultiJson) }
  end
end
