module Influxdb
  module Api
    module Namespaces
      class ContinuousQueries < WithDatabase
        resource_path '/continuous_queries'

        def create(query)
          super(query: query)
        end
      end
    end
  end
end
