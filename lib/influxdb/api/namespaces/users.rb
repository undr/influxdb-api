module Influxdb
  module Api
    module Namespaces
      class Users < WithDatabase
        resource_path '/users'

        def find(name)
          perform_get(resource_path(name))
        rescue Influxdb::Api::Client::Errors::BadRequest => e
          raise e unless e.message =~ /Invalid username/
          nil
        end

        def update(name, attributes)
          perform_post(resource_path(name), {}, attributes)
          true
        end

        def delete(*_)
          super
        rescue Influxdb::Api::Client::Errors::BadRequest => e
          raise e unless e.message =~ /User (.*) doesn\'t exist/
          false
        end
      end
    end
  end
end
