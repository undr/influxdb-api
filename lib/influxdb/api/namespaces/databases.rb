module Influxdb
  module Api
    module Namespaces
      class Databases < Base
        resource_path '/db'

        def create(name)
          super(name: name)
        end
      end
    end
  end
end
