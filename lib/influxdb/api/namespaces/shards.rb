module Influxdb
  module Api
    module Namespaces
      class Shards < Base
        resource_path '/cluster/shards'

        def create(attributes)
          attributes['startTime'] = cast_datetime(attributes['startTime']) if attributes['startTime']
          attributes[:startTime] = cast_datetime(attributes[:startTime]) if attributes[:startTime]
          attributes['endTime'] = cast_datetime(attributes['endTime']) if attributes['endTime']
          attributes[:endTime] = cast_datetime(attributes[:endTime]) if attributes[:endTime]

          super(attributes)
        end

        private

        def cast_datetime(value)
          value = value.to_i if value && !value.is_a?(Integer)
          value
        end
      end
    end
  end
end
