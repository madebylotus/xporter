module Xporter
  class Exporter
    module DSL
      extend ActiveSupport::Concern

      included do
        private_class_method :column,
                             :model,
                             :transform
      end

      class_methods do
        def column(attribute_name, title = nil, &block)
          self._columns << Column.new(attribute_name, title, &block)
        end

        def model(resource_class)
          self._resource_class = resource_class
        end

        def transform(&block)
          raise 'Block must accept two arguments' unless block.arity == 2

          self._record_transform = block
        end
      end
    end
  end
end
