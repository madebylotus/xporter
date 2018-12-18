module Xporter
  class Column
    attr_reader :attribute_name, :title, :block

    def initialize(attribute_name, title = nil, &block)
      @attribute_name = attribute_name
      @title = title
      @block = block || ->(model){ model.public_send(attribute_name) }
    end

    def data(model)
      block.call(model)
    end

    def title_from(resource_class)
      return title if title.present?
      return attribute_name.to_s.titleize unless resource_class.respond_to?(:human_attribute_name)

      resource_class.human_attribute_name(attribute_name)
    end
  end
end
