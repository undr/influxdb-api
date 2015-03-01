# Ruby client for InfluxDB

[![Build Status](https://travis-ci.org/undr/influxdb-api.svg?branch=master)](https://travis-ci.org/undr/influxdb-api) [![Code Climate](https://codeclimate.com/github/undr/influxdb-api/badges/gpa.svg)](https://codeclimate.com/github/undr/influxdb-api) [![Gem Version](https://badge.fury.io/rb/influxdb-api.svg)](http://badge.fury.io/rb/influxdb-api)

It tested on influxdb till 0.8.3.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'influxdb-api'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install influxdb-api
```

## Usage

### Client configuration

There are two ways to obtain a fully-configured client:

- Get default client with default configuration, or
- Create client with custom configuration.

To configure default client you should pass a block to the method `Influxdb::Api.configure`.

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

  # Turn on or turn off logging
  c.log = true
  # or
  c.logger = Logger.new('./log/influxdb-api.log')

  # Custom serializer. It should respond to methods #load and #dump
  # Default: MultiJson
  c.serializer = CustomJsonSerializer.new

  # Connection selector.
  # Default: Influxdb::Api::Client::Selector::RoundRobin
  c.selector = Influxdb::Api::Client::Selector::Random.new
end

client = Influxdb::Api.client

client.config.user
# => "root"
client.config.retry_on_failure
# => 3
```

Also, you can create client with custom configuration. Configuration will be inherited from default configuration and all needed options will be overridden.

```ruby
client = Influxdb::Api.new do |c|
  c.user = 'dbuser'
  c.password = 'dbpassword'
end

client.config.user
# => "dbuser"
client.config.retry_on_failure
# => 3
```

### Available methods

```ruby
client = Influxdb::Api.client

client.databases.all
# => [{"name"=>"dbname"}]
client.databases.create('dbname')
# => true
client.databases.delete('dbname')
# => true

database = client.databases('dbname')

database.series.all
# => ["cpu"]
database.series.execute('select * from /.*/')
# => {"cpu"=>[{"time"=>1411173197058, "sequence_number"=>200001, "value"=>13.5}]}
database.series.raw_execute('select * from /.*/')
# => [{"name"=>"cpu", "columns"=>["time", "sequence_number", "value"], "points"=>[[1411173197058, 200001, 13.5]]}]
database.series.write(:cpu, value: 13.5)
# => true
database.series.write(:cpu, [{ value: 13.5 }, { value: 10.0 }])
# => true
database.series.write(cpu: { value: 43.9 }, memory: { value: 2500853760 })
# => true
database.series.delete('seriesname')
# => true

database.users.all
# => [{"name"=>"username", "isAdmin"=>true}]
database.users.find('username')
# => {"name"=>"username", "isAdmin"=>true}
database.users.create(name: 'username', password: 'mypass', isAdmin: true)
# => true
database.users.update('username', admin: false)
# => true
database.users.delete('username')
# => true

database.continuous_queries.all
# => [{"id"=>1, "query"=>"select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean"}]
database.continuous_queries.create('select MEAN(user) as user_mean from cpu group by time(1m) into cpu.1m.user_mean')
# => true
database.continuous_queries.delete(1)
# => true

database.shard_spaces.all
# => [{"name"=>"default", "database"=>"influxdb_api", "regex"=>"/.*/", "retentionPolicy"=>"inf", "shardDuration"=>"7d", "replicationFactor"=>1, "split"=>1},
#  {"name"=>"default", "database"=>"influxdb_ruby", "regex"=>"/.*/", "retentionPolicy"=>"inf", "shardDuration"=>"7d", "replicationFactor"=>1, "split"=>1}]
database.shard_spaces.create(attrs)
database.shard_spaces.update('spacename', attrs)
database.shard_spaces.delete('spacename')

client.cluster_admins.all
# => [{"name"=>"root"}]
client.cluster_admins.create(name: 'username', password: 'pass')
# => true
client.cluster_admins.update('username', password: 'newpass')
# => true
client.cluster_admins.delete('username')
# => true

client.servers.all
# => [{"id"=>1,
#  "isLeader"=>true,
#  "isUp"=>false,
#  "leaderRaftConnectString"=>"http://undr.local:8090",
#  "leaderRaftName"=>"97f5a3f53052a5a7",
#  "protobufConnectString"=>"undr.local:8099",
#  "raftConnectionString"=>"http://undr.local:8090",
#  "raftName"=>"97f5a3f53052a5a7",
#  "state"=>4,
#  "stateName"=>"Potential"}]
client.servers.delete(1)
# => true

client.shards.all
# => {"longTerm"=>[],
#  "shortTerm"=>
#   [{"endTime"=>1411603200, "id"=>2, "serverIds"=>[1], "startTime"=>1410998400}, {"endTime"=>1410998400, "id"=>1, "serverIds"=>[1], "startTime"=>1410393600}]}

client.shards.create(attrs)
# => true
client.shards.delete(1)
# => true

v = client.version
# => "InfluxDB v0.8.3 (git: fbf9a474055051c64e947f2a071388ee009a08d5) (leveldb: 1.15)"
v > '0.8.6'
# => false
v > '0.8'
# => true
v.major
# => 0
v.minor
# => 8
v.patch
# => 3
v.git
# => "fbf9a474055051c64e947f2a071388ee009a08d5"
v.engine
# "leveldb: 1.15.0"
v.engine.major
# => 1
v.engine.minor
# => 15
v.engine.patch
# => 0
client.sync?
# => true
client.interfaces
# => ["default"]
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
