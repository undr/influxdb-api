module Influxdb
  module Api
    class Client
      class Response
        attr_reader :status, :body, :headers

        def initialize(status, body, headers = {})
          @status, @body, @headers = status, body, headers
          @body = body.force_encoding('UTF-8') if body.respond_to?(:force_encoding)
        end
      end
    end
  end
end
