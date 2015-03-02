module Influxdb
  module Api
    class Database
      attr_reader :client, :name

      def initialize(client, name)
        @client = client
        @name = name
      end

      def series
        @series ||= Namespaces::Series.new(client, name)
      end

      def users
        @users ||= Namespaces::Users.new(client, name)
      end

      def continuous_queries
        @continuous_queries ||= if client.version > '0.8.3'
          Namespaces::ContinuousQueries::Sql.new(client, name)
        else
          Namespaces::ContinuousQueries::Api.new(client, name)
        end
      end

      def shard_spaces
        @shard_spaces ||= begin
          version = client.version
          raise(
            UnsupportedFeature,
            "Shard space's API is supported only after 0.7.3 version. Current is #{version.to_s(:mini)}"
          ) if version < '0.8.3'

          Namespaces::ShardSpaces.new(client, name)
        end
      end
    end
  end
end

