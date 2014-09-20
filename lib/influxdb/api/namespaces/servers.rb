module Influxdb
  module Api
    module Namespaces
      class Servers < Base
        resource_path '/cluster/servers'

        undef_method(:create) if method_defined?(:create)

      end
    end
  end
end
