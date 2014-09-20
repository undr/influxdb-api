module Influxdb
  module Api
    module Namespaces
      class ShardSpaces < WithDatabase
        resource_path '/cluster/shard_spaces'

        def all
          perform_get(resource_path)
        end

        def create(attributes)
          perform_post(resource_path(database_name), {}, attributes)
          true
        end

        def update(name, attributes)
          perform_post(resource_path(database_name, name), {}, attributes)
          true
        end

        def delete(name)
          perform_delete(resource_path(database_name, name))
          true
        end

        protected

        def path_prefix
        end
      end
    end
  end
end
