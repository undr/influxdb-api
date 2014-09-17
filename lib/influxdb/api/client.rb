module Influxdb
  module Api
    class Client
      def initialize
        @connection_pool = ConnectionPool.new
        @last_request_at = Time.now
        @resurrect_after = 60
      end

      def perform_request(method, path, params = {}, body = nil, &block)
        response = with_retry(path, params) do |connection, url|
          connection.basic_auth(config.user, config.password)
          headers = { 'Content-Type' => 'application/json' }

          connection.run_request(method.downcase.to_sym, url, (body ? convert_to_json(body) : nil), headers, &block)
        end

        raise_transport_error(response) if response.status.to_i >= 300

        json = config.serializer.load(response.body) if response.headers && response.headers["content-type"] =~ /json/

        Response.new(response.status, json || response.body, response.headers)
      ensure
        @last_request_at = Time.now
      end

      private

      attr_reader :connection_pool, :last_request_at, :resurrect_after

      def with_retry(path, params, &block)
        tries = 0

        begin
          tries += 1
          connection = get_connection or raise Error.new("Cannot get new connection from pool.")

          response = block.call(connection.connection, connection.full_path(path, params))

          connection.healthy! if connection.failures > 0
          Response.new(response.status, response.body, response.headers)
        rescue ::Faraday::Error::ConnectionFailed, ::Faraday::Error::TimeoutError => e
          logger.error "[#{e.class}] #{e.message} #{connection.host.inspect}" if logger

          connection.dead!

          raise e unless config.retry_on_failure

          logger.warn "[#{e.class}] Attempt #{tries} connecting to #{connection.host.inspect}" if logger

          retry if tries < config.retry_on_failure.to_i

          logger.fatal "[#{e.class}] Cannot connect to #{connection.host.inspect} after #{tries} tries" if logger
          raise e
        rescue Exception => e
          host = connection.host if connection
          logger.fatal "[#{e.class}] #{e.message} (#{host.inspect})" if logger
          raise e
        end
      end

      def raise_transport_error(response)
        logger.fatal "[#{response.status}] #{response.body}" if logger
        error = ERRORS[response.status] || ServerError
        raise error.new "[#{response.status}] #{response.body}"
      end

      def resurrect_dead_connections!
        connection_pool.dead.each{|c| c.resurrect! }
      end

      def get_connection
        resurrect_dead_connections! if Time.now > last_request_at + resurrect_after
        connection_pool.get_connection
      end

      def convert_to_json(body, options = {})
        body.is_a?(String) ? body : config.serializer.dump(body, options)
      end

      def logger
        config.logger
      end

      def config
        Influxdb::Api.config
      end
    end
  end
end

require_relative 'client/response'
require_relative 'client/selector'
require_relative 'client/connection'
require_relative 'client/connection_pool'
require_relative 'client/errors'
