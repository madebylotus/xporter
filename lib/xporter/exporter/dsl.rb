module Xporter
  class Exporter
    module DSL
      extend ActiveSupport::Concern

      included do
        private_class_method :column,
                             :decorates,
                             :model,
                             :transform
      end

      class_methods do
        def column(attribute_name, title = nil, &block)
          self._columns << Column.new(attribute_name, title, &block)
        end

        def decorates(boolean_or_class)
          if boolean_or_class.nil? || boolean_or_class == false
            self._decorates = false
            self._decorator_class = nil
            return
          end

          self._decorates = true

          if boolean_or_class.is_a?(Class)
            self._decorator_class = boolean_or_class
          end
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
