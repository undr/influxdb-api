module Influxdb
  module Api
    module Namespaces
      class Users < WithDatabase
        resource_path '/users'

        def find(name)
          perform_get(resource_path(name))
        end

        def update(name, attributes)
          perform_post(resource_path(name), {}, attributes)
          true
        end
      end
    end
  end
end
