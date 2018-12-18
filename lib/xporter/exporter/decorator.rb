module Xporter
  class Exporter
    module Decorator
      extend ActiveSupport::Concern

      included do
        class_attribute :_decorates, instance_accessor: false
        class_attribute :_decorator_class, instance_accessor: false

        self._decorates = false
        self._decorator_class = nil

        private_class_method :decorates
      end

      class_methods do
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

      def decorator?
        self.class._decorates == true
      end

      def decorate(record)
        if self.class._decorator_class.present?
          self.class._decorator_class.new(record, view_context)
        else
          record.decorate(view_context)
        end
      end
    end
  end
end
