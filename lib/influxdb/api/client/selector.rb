module Influxdb
  module Api
    class Client
      module Selector
        class Base
          def select_from
            raise NoMethodError, "Implement this method in the selector implementation."
          end
        end

        class Random < Base
          def select_from(connections)
            connections.to_a.sample
          end
        end

        class RoundRobin < Base
          def select_from(connections)
            @current = @current.nil? ? 0 : @current + 1
            @current = 0 if @current >= connections.size
            connections[@current]
          end
        end
      end
    end
  end
end
