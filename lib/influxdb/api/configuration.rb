module Influxdb
  module Api
    class Configuration
      attr_accessor :resurrect_timeout, :retry_on_failure, :connection_options,
        :serializer, :log, :selector, :user, :password

      attr_writer :logger
      attr_reader :hosts

      class Host
        DEFAULT = ['http://localhost:8086'].freeze
        DEFAULT_PORT = 8086
        DEFAULT_PROTOCOL = 'http'.freeze

        def initialize(source)
          @source = to_hash(source)
        end

        def build
          result = "#{protocol}://"
          result << "#{user}:#{password}@" if user
          result << "#{host}:#{port}"
          result << path if path
          result
        end

        private

        attr_reader :source

        def to_hash(source)
          case source
          when String
            source =~ /^[a-z]+\:\/\// ? to_hash(URI.parse(source)) : Hash[[:host, :port].zip(source.split(?:))]
          when URI
            {
              scheme: source.scheme,
              user: source.user,
              password: source.password,
              host: source.host,
              path: source.path,
              port: source.port.to_s
            }
          when Hash
            source
          else
            raise ArgumentError, "Please pass host as a String, URI or Hash -- #{source.class} given."
          end
        end

        def protocol
          source[:scheme] || DEFAULT_PROTOCOL
        end

        def port
          source[:port] || DEFAULT_PORT
        end

        [:host, :user, :password, :path].each do |method|
          define_method(method) do
            source[method]
          end
        end
      end

      DEFAULT_LOGGER = ->{
        require 'logger'
        logger = Logger.new(STDERR)
        logger.progname = 'influxdb'
        logger.formatter = ->(severity, datetime, progname, msg){ "#{datetime}: #{msg}\n" }
        logger
      }

      def initialize
        @log = false
        @user = 'root'
        @password = 'root'
        @serializer = MultiJson
        @connection_options = {}
        @connection_block = nil
        @retry_on_failure = false
        @resurrect_timeout = 60
        @hosts = Host::DEFAULT
        @selector = Client::Selector::RoundRobin.new
      end

      def logger
        @logger ||= log ? DEFAULT_LOGGER.call : nil
      end

      def hosts=(value)
        value = [value] if value.is_a?(Hash)
        @hosts = Array(value).map(&method(:normalize_host))
      end

      def connection_block(&block)
        if block_given?
          @connection_block = block
        else
          @connection_block
        end
      end

      private

      def normalize_host(host)
        Host.new(host).build
      end
    end
  end
end
