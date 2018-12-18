module Xporter
  class Exporter
    module Streaming
      extend ActiveSupport::Concern

      class_methods do
        def stream(*args)
          new.stream(*args)
        end
      end

      def stream(collection, stream)
        stream.write CSV.generate_line(headers)

        @collection = collection

        content.each do |row|
          stream.write CSV.generate_line(row)
        end
      end
    end
  end
end
