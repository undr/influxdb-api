module Influxdb
  module Api
    module Namespaces
      class Databases < Base
        resource_path '/db'

        def create(name)
          super(name: name)
        end

        def delete(*_)
          return_false_if_doesnt_exist('Database'){ super }
        end
      end
    end
  end
end
