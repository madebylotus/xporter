module Xporter
  class Exporter
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

    # class methods
    class << self
      def inherited(other) # reset so that each subclass has it's own collection
        other._columns = []
      end

      def stream(*args)
        new.stream(*args)
      end

      def generate(*args)
        new.generate(*args)
      end

      private

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

    def generate(collection)
      @collection = collection

      CSV.generate do |csv|
        csv << headers

        content.each do |row|
          csv << row
        end
      end
    end

    def stream(collection, stream)
      stream.write CSV.generate_line(headers)

      @collection = collection

      content.each do |row|
        stream.write CSV.generate_line(row)
      end
    end

    def context=(options={})
      @_record_context = options
    end

    private

    def view_context
      @view_context ||= begin
        ActionView::Base.new(ActionController::Base.view_paths).tap do |view|
          view.class_eval do
            include Rails.application.routes.url_helpers
            include ApplicationHelper
          end
        end
      end
    end

    def headers
      self.class._columns.map do |column|
        column.title_from(self.class._resource_class)
      end
    end

    def content
      each_item.map do |record|
        record = transform(record) if transform?

        if decorator?
          if self.class._decorator_class.present?
            record = self.class._decorator_class.new(record, view_context)
          else
            record = record.decorate(view_context)
          end
        end

        self.class._columns.map do |column|
          column.data(record)
        end
      end
    end

    def each_item(&block)
      return @collection.each.lazy unless @collection.respond_to?(:find_each)

      @collection.find_each(batch_size: self.class._batch_size).lazy
    end

    def transform(record)
      self.class._record_transform.call(record, @_record_context)
    end

    def decorator?
      self.class._decorates == true
    end

    def transform?
      self.class._record_transform.present?
    end
  end
end
