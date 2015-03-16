module Influxdb
  module Api
    module Namespaces
      class Base
        attr_reader :client

        class << self
          attr_accessor :_resource_path

          protected

          def resource_path(value)
            self._resource_path = value
          end
        end

        def initialize(client)
          @client = client
        end

        def all
          perform_get(resource_path)
        end

        def create(attributes)
          perform_post(resource_path, {}, attributes)
          true
        end

        def delete(name)
          perform_delete(resource_path(name))
          true
        end

        protected

        def return_false_if_doesnt_exist(type)
          yield
        rescue Influxdb::Api::Client::Errors::BadRequest => e
          raise e unless e.message =~ /#{type} (.*) doesn\'t exist/
          false
        end

        def resource_path(*args)
          [path_prefix, self.class._resource_path, path_postfix, args].compact.flatten.join(?/).squeeze(?/)
        end

        def path_prefix
        end

        def path_postfix
        end

        def perform_get(path, params = {})
          client.perform_request('get', path, params || {}).body
        end

        def perform_post(path, params, body)
          client.perform_request('post', path, params || {}, body).body
        end

        def perform_delete(path, params = {}, body = nil)
          client.perform_request('delete', path, params || {}, body).body
        end
      end
    end
  end
end
