module Influxdb
  module Api
    class Client
      class Connection
        attr_reader :host, :connection, :failures, :dead_since

        def initialize(host, connection)
          @host = host
          @connection = connection
          @failures = 0
        end

        def full_path(path, params={})
          path + (params.empty? ? '' : "?#{::Faraday::Utils::ParamsHash[params].to_query}")
        end

        def dead?
          !!@dead
        end

        def dead!
          @dead = true
          @failures += 1
          @dead_since = Time.now
          self
        end

        def alive!
          @dead = false
          self
        end

        def healthy!
          @dead = false
          @failures = 0
          self
        end

        def resurrect!
          alive! if resurrectable?
          self
        end

        def resurrectable?
          Time.now > dead_since + (config.resurrect_timeout * 2 ** (failures - 1))
        end

        def to_s
          "<#{self.class.name} host: #{host} (#{dead? ? 'dead since ' + dead_since.to_s : 'alive'})>"
        end

        def config
          Influxdb::Api.config
        end
      end
    end
  end
end
