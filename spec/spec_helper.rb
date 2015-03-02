require 'bundler'
Bundler.require(:default, :test)
require 'support/version_resolver'

def allow_localhost
  WebMock.disable_net_connect!(allow_localhost: true)
  yield
ensure
  WebMock.disable_net_connect!(allow_localhost: false)
end

version_resolver = allow_localhost{ VersionResolver.new }

puts "InfluxDB: #{version_resolver.server_version}"

WebMock.disable_net_connect!(allow_localhost: false)

RSpec.configure do |config|
  config.mock_with :rspec
  config.filter_run_excluding version: ->(v){ !version_resolver.fit?(v) }
  #config.filter_run_excluding((VERSIONS - [INFLUXDB_VERSION]).map{|v| { v => true } }.inject(&:merge))

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
