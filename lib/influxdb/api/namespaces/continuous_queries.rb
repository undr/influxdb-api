module Influxdb
  module Api
    module Namespaces
      module ContinuousQueries
        class Api < WithDatabase
          resource_path '/continuous_queries'

          def create(query)
            super(query: query)
          end
        end

        class Sql < WithDatabase
          def create(query)
            series.execute(query)
            true
          end

          def all
            series.execute('LIST CONTINUOUS QUERIES')['continuous queries']
          end

          def delete(id)
            series.execute("DROP CONTINUOUS QUERY #{id}")
            true
          end

          private

          def series
            client.databases(database_name).series
          end
        end
      end
    end
  end
end
