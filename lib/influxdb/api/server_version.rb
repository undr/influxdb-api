module Influxdb
  module Api
    class ServerVersion
      include Comparable

      class Engine
        attr_reader :name, :major, :minor, :patch

        def initialize(name, major, minor, patch)
          @name, @major, @minor, @patch = name, major, minor, patch
        end

        def to_s
          "%s: %s.%s.%s" % [name, major, minor, patch]
        end

        def inspect
          to_s.inspect
        end
      end

      # InfluxDB v0.7.3 (git: 023abcdef) (leveldb: 1.7)
      REGEXP = /^InfluxDB\sv(\d+)\.(\d+)\.(\d+)\s\(git:\s([0-9abcdef]+)\)\s\((\w+):\s(\d+)\.(\d+)\)$/

      attr_reader :source, :git, :engine, :major, :minor, :patch

      def initialize(source)
        @source = source
        parse!
      end

      def <=>(other)
        other_major, other_minor, other_patch = (other.to_s.split('.', 3) + [0] * 3).first(3).map(&:to_i)
        [major <=> other_major, minor <=> other_minor, patch <=> other_patch].detect{|c| c != 0 } || 0
      end

      def to_s
        source
      end

      def inspect
        to_s.inspect
      end

      private

      def parse!
        matched = REGEXP.match(source)

        @major = matched[1].to_i
        @minor = matched[2].to_i
        @patch = matched[3].to_i
        @git = matched[4]
        @engine = build_engine(matched)
      end

      def build_engine(matched)
        Engine.new(matched[5], matched[6].to_i, matched[7].to_i, matched[8].to_i)
      end
    end
  end
end
