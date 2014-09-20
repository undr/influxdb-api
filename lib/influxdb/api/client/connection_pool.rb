module Influxdb
  module Api
    class Client
      class ConnectionPool
        attr_reader :config

        def initialize(config = Influxdb::Api.config)
          @config = config
          @connections = build_connections
        end

        def connections
          @connections.reject{|c| c.dead? }
        end
        alias :alive :connections

        def dead
          @connections.select{|c| c.dead? }
        end

        def all
          @connections
        end

        def each(&block)
          connections.each(&block)
        end

        def get_connection
          if connections.empty? && dead_connection = dead.sort{|a, b| a.failures <=> b.failures }.first
            dead_connection.alive!
          end
          config.selector.select_from(alive)
        end

        def build_connections
          config.hosts.map do |host|
            Connection.new(
              host,
              ::Faraday::Connection.new(
                host,
                config.connection_options,
                &config.connection_block
              ),
              config
            )
          end
        end
      end
    end
  end
end
