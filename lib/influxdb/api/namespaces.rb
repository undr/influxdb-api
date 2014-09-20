require_relative 'namespaces/base'
require_relative 'namespaces/with_database'
require_relative 'namespaces/databases'
require_relative 'namespaces/series'
require_relative 'namespaces/users'
require_relative 'namespaces/continuous_queries'
require_relative 'namespaces/shard_spaces'
require_relative 'namespaces/cluster_admins'
require_relative 'namespaces/servers'
require_relative 'namespaces/shards'

module Influxdb
  module Api
    module Namespaces
      def databases(name = nil)
        if name
          Database.new(self, name)
        else
          @databases ||= Databases.new(self)
        end
      end
      alias_method :dbs, :databases

      def cluster_admins
        @cluster_admins ||= ClusterAdmins.new(self)
      end

      def servers
        @servers ||= Servers.new(self)
      end

      def shards
        @shards ||= Shards.new(self)
      end

      def version
        ServerVersion.new(perform_request('get', '/ping').headers['x-influxdb-version'])
      end

      def sync?
        config.serializer.load(perform_request('get', '/sync').body)
      end
      alias_method :cluster_synchronized?, :sync?

      def interfaces
        perform_request('get', '/interfaces').body
      end
    end
  end
end
