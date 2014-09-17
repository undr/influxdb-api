require 'spec_helper'

describe Influxdb::Api::Client::ConnectionPool do
  subject{ Influxdb::Api::Client::ConnectionPool.new }

  before{ Influxdb::Api.config = Influxdb::Api::Configuration.new }
  after{ Influxdb::Api.config = Influxdb::Api::Configuration.new }

  describe '#initialize' do
    before do
      Influxdb::Api.config.hosts = ['localhost', 'influxdb.server.com']
      Influxdb::Api.config.connection_block{|conn|  }
      Influxdb::Api.config.connection_options = { key: :value }
    end

    let(:conn){ double(:conn) }

    specify do
      expect(::Faraday::Connection).to receive(:new).with(
        'http://localhost:8086',
        { key: :value },
        &Influxdb::Api.config.connection_block
      ).and_return(conn)

      expect(Influxdb::Api::Client::Connection).to receive(:new).with('http://localhost:8086', conn).
        and_return(conn)

      expect(::Faraday::Connection).to receive(:new).with(
        'http://influxdb.server.com:8086',
        { key: :value },
        &Influxdb::Api.config.connection_block
      ).and_return(conn)

      expect(Influxdb::Api::Client::Connection).to receive(:new).with('http://influxdb.server.com:8086', conn).
        and_return(conn)

      expect(subject.all).to eq([conn, conn])
    end
  end

  describe '#get_connection' do
    let(:conn){ double(:conn) }

    before{ allow(Influxdb::Api.config.selector).to receive(:select_from).and_return(conn) }

    specify{ expect(subject.get_connection).to eq(conn) }
  end

  describe '#connections' do
    before do
      Influxdb::Api.config.hosts = ['localhost', 'influxdb01.server.com', 'influxdb02.server.com']
      subject.all.first.dead!
    end

    specify{ expect(subject.connections.size).to eq(2) }
  end

  describe '#dead' do
    before do
      Influxdb::Api.config.hosts = ['localhost', 'influxdb01.server.com', 'influxdb02.server.com']
      subject.all.first.dead!
    end

    specify{ expect(subject.dead.size).to eq(1) }
  end
end
