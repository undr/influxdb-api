module Influxdb
  module Api
    module Namespaces
      class ClusterAdmins < Base
        resource_path '/cluster_admins'

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
