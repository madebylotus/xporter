require "xporter/exporter/dsl"
require "xporter/exporter/settings"
require "xporter/exporter/streaming"

module Xporter
  class Exporter
    include Settings
    include DSL
    include Streaming

    # class methods
    class << self
      def inherited(other) # reset so that each subclass has it's own collection
        other._columns = []
      end

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
