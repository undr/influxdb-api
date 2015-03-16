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
          return_false_if_doesnt_exist('User'){ super }
        end
      end
    end
  end
end
