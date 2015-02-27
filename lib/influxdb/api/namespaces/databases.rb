module Influxdb
  module Api
    module Namespaces
      class Databases < Base
        resource_path '/db'

        def create(name)
          super(name: name)
        end

        def delete(*_)
          super
        rescue Influxdb::Api::Client::Errors::BadRequest => e
          raise e unless e.message =~ /Database (.*) doesn\'t exist/
          false
        end
      end
    end
  end
end
