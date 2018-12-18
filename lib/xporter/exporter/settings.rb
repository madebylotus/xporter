module Xporter
  class Exporter
    module Settings
      extend ActiveSupport::Concern

      included do
        class_attribute :_columns, instance_accessor: false
        class_attribute :_decorates, instance_accessor: false
        class_attribute :_decorator_class, instance_accessor: false
        class_attribute :_resource_class, instance_accessor: false
        class_attribute :_record_transform, instance_accessor: false
        class_attribute :_batch_size, instance_accessor: false

        self._columns = []
        self._decorates = false
        self._decorator_class = nil
        self._batch_size = 500.freeze
      end

      class_methods do
      end
    end
  end
end
