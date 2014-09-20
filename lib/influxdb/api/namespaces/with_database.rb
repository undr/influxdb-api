module Influxdb
  module Api
    module Namespaces
      class WithDatabase < Base
        attr_reader :database_name

        def initialize(client, database_name)
          @client = client
          @database_name = database_name
        end

        protected

        def path_prefix
          "/db/#{database_name}"
        end
      end
    end
  end
end
