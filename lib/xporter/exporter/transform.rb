module Xporter
  class Exporter
    module Transform
      extend ActiveSupport::Concern

      included do
        class_attribute :_record_transform, instance_accessor: false
      end

      class_methods do
        def transform(&block)
          raise 'Block must accept two arguments' unless block.arity == 2

          self._record_transform = block
        end
      end

      def context=(options={})
        @_record_context = options
      end

      private

      def transform(record)
        self.class._record_transform.call(record, @_record_context)
      end

      def transform?
        self.class._record_transform.present?
      end
    end
  end
end
