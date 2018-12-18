require "xporter/exporter/decorator"
require "xporter/exporter/dsl"
require "xporter/exporter/generator"
require "xporter/exporter/settings"
require "xporter/exporter/streaming"
require "xporter/exporter/transform"

module Xporter
  class Exporter
    include Decorator
    include Settings
    include Transform
    include DSL
    include Generator
    include Streaming

    # reset so that each subclass has it's own collection
    def self.inherited(other)
      other._columns = []
    end
  end
end
