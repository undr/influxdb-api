require 'multi_json'
require 'faraday'

require_relative 'api/version'
require_relative 'api/configuration'
require_relative 'api/client'

module Influxdb
  module Api
    extend self

    attr_writer :client, :config

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
