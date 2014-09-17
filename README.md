# InfluxdbClient

## Installation

Add this line to your application's Gemfile:

    gem 'influxdb-api'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install influxdb-api

## Usage

### Configurations

```ruby
Influxdb::Api.configure do |c|
  # Credentials
  c.user = 'root'
  c.password = 'root'

  # Servers pool
  c.hosts = [
    { host: 'influx01.server.com', port: 8086 },
    'influx02.server.com',
    URI.parse('http://influx03.server.com:8086')
  ]

  # By default it does not try to send request again if request failed.
  # You can change it by specifying number of trying.
  c.retry_on_failure = 3

  # Faraday connection options
  c.connection_options = {}

  # Faraday connection block
  c.connection_block do |conn|
    conn.adapter :typhoeus
  end

  c.log = true
  # or
  c.logger = Logger.new('./log/influxdb-api.log')

  # Custom serializer. It should respond to methods #load and #dump (Default: MultiJson)
  c.serializer = CustomJsonSerializer.new

  # Connection selector. Default: Influxdb::Api::Selector::RoundRobin
  c.selector = Influxdb::Api::Selector::Random
end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
