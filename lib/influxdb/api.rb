require 'multi_json'
require 'faraday'
require 'ostruct'

require_relative 'api/version'
require_relative 'api/extensions'
require_relative 'api/namespaces'
require_relative 'api/database'
require_relative 'api/server_version'

require_relative 'api/configuration'
require_relative 'api/client'

module Influxdb
  module Api
    class Error < StandardError;end
    class UnsupportedFeature < Error;end

    extend self

    attr_writer :client, :config

    def new
      instance_config = config.dup
      yield instance_config if block_given?
      Client.new(instance_config)
    end

    def client
      @client ||= Client.new
    end

    def config
      @config ||= Configuration.new
    end

    def configure
      yield config
    end
  end
end
