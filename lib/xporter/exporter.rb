require "xporter/exporter/decorator"
require "xporter/exporter/dsl"
require "xporter/exporter/generator"
require "xporter/exporter/settings"
require "xporter/exporter/streaming"

module Xporter
  class Exporter
    include Decorator
    include Settings
    include DSL
    include Generator
    include Streaming

    # class methods
    class << self
      def inherited(other) # reset so that each subclass has it's own collection
        other._columns = []
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
