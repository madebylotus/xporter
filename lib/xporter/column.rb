module Xporter
  class Column
    attr_reader :attribute_name, :title, :block

    def initialize(attribute_name, title, &block)
      @attribute_name = attribute_name
      @title = title
      @block = block || ->(model){ model.public_send(attribute_name) }
    end

    def data(model)
      block.call(model)
    end
  end
end
