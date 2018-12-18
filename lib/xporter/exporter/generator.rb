module Xporter
  class Exporter
    module Generator
      extend ActiveSupport::Concern

      class_methods do
        def generate(*args)
          new.generate(*args)
        end
      end

      def generate(collection)
        @collection = collection

        CSV.generate do |csv|
          csv << headers

          content.each do |row|
            csv << row
          end
        end
      end

      private

      def headers
        columns.map do |column|
          column.title_from(self.class._resource_class)
        end
      end

      def content
        each_item.map do |record|
          record = transform(record) if transform?
          record = decorate(record) if decorator?

          columns.map do |column|
            column.data(record)
          end
        end
      end

      def each_item(&block)
        return @collection.each.lazy unless @collection.respond_to?(:find_each)

        @collection.find_each(batch_size: self.class._batch_size).lazy
      end
    end
  end
end
