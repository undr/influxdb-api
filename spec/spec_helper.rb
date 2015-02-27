require 'bundler'
Bundler.require(:default, :test)

VERSIONS = ['0.7.3', '0.8.3', '0.8.8']

def allow_localhost
  WebMock.disable_net_connect!(allow_localhost: true)
  yield
ensure
  WebMock.disable_net_connect!(allow_localhost: false)
end

def get_version
  allow_localhost do
    if ENV['INFLUXDB_VERSION']
      [ENV['INFLUXDB_VERSION'], ENV['INFLUXDB_VERSION']]
    else
      v = Influxdb::Api.client.version
      if v < '0.8'
        ['0.7.3', v.to_s(:mini)]
      elsif v >= '0.8.0'&& v <= '0.8.3'
        ['0.8.3', v.to_s(:mini)]
      else
        ['0.8.8', v.to_s(:mini)]
      end
    end
  end
end

INFLUXDB_VERSION, REAL_INFLUXDB_VERSION = get_version

puts "InfluxDB: #{INFLUXDB_VERSION} (#{REAL_INFLUXDB_VERSION})"

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  config.mock_with :rspec

  config.filter_run_excluding((VERSIONS - [INFLUXDB_VERSION]).map{|v| { v => true } }.inject(&:merge))

  config.around :each, integration: true do |example|
    allow_localhost{ example.run }
  end

  config.around :each, time_freeze: ->(v){ v.is_a?(Date) || v.is_a?(Time) || v.is_a?(String) } do |example|
    datetime = if example.metadata[:time_freeze].is_a?(String)
      DateTime.parse(example.metadata[:time_freeze])
    else
      example.metadata[:time_freeze]
    end

    Timecop.freeze(datetime){ example.run }
  end

  config.around :each, time_travel: ->(v){ v.is_a?(Date) || v.is_a?(Time) || v.is_a?(String) } do |example|
    datetime = if example.metadata[:time_travel].is_a?(String)
      DateTime.parse(example.metadata[:time_travel])
    else
      example.metadata[:time_travel]
    end

    Timecop.travel(datetime){ example.run }
  end
end
