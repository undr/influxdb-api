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
        @continuous_queries ||= Namespaces::ContinuousQueries.new(client, name)
      end

      def shard_spaces
        @shard_spaces ||= Namespaces::ShardSpaces.new(client, name)
      end
    end
  end
end

