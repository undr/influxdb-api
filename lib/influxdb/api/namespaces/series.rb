module Influxdb
  module Api
    module Namespaces
      class Series < WithDatabase
        resource_path '/series'

        undef_method(:create) if method_defined?(:create)

        def all
          raw_execute('list series').map{|s| s['name']}
        end

        def write(*series)
          series = if series.first.is_a?(String) || series.first.is_a?(Symbol)
            { series.shift => series.shift }
          else
            series.shift
          end

          series = series.map{|name, points| writing_block(name, Array.wrap(points)) }
          perform_writing(series)
        end

        def execute(*args)
          raw_execute(*args).each_with_object({}) do |block_of_series, result|
            result[block_of_series['name']] = block_of_series['points'].map do |point|
              Hash[block_of_series['columns'].zip(point)]
            end
          end
        end

        def raw_execute(query_string, time_precision = nil)
          params = { q: query_string }
          params[:time_precision] = time_precision if time_precision
          perform_get(resource_path, params)
        end

        private

        def perform_writing(series, time_precision = nil)
          params = { time_precision: time_precision } if time_precision
          perform_post(resource_path, params, series)
          true
        end

        def writing_block(name, points)
          { name: name, columns: points.first.keys, points: points.map(&:values) }
        end
      end
    end
  end
end
