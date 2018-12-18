module Xporter
  module FileStreamer
    extend ActiveSupport::Concern

    included do
      include ActionController::Live
    end

    def stream_file(filename, extension, &block)
      response.headers["Content-Type"] = "application/octet-stream"
      response.headers["Content-Disposition"] = "attachment; filename=#{filename}.#{extension}"

      begin
        yield response.stream
      ensure
        response.stream.close
      end
    end
  end
end
