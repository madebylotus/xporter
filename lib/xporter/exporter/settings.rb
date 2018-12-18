module Xporter
  class Exporter
    module Settings
      extend ActiveSupport::Concern

      included do
        class_attribute :_columns, instance_accessor: false
        class_attribute :_resource_class, instance_accessor: false
        class_attribute :_record_transform, instance_accessor: false
        class_attribute :_batch_size, instance_accessor: false

        self._columns = []
        self._batch_size = 500.freeze
      end

      def columns
        self.class._columns
      end
    end
  end
end
