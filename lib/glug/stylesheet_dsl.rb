# frozen_string_literal: true

module Glug
  # Defines the methods available to the DSL
  class StylesheetDSL
    def initialize(impl)
      @__impl = impl
    end

    def layer(id, opts = {}, &block)
      @__impl.layer(id, opts, &block)
    end

    def source(source_name, opts = {})
      @__impl.source(source_name, opts)
    end

    def include_file(filename)
      @__impl.include_file(filename)
    end

    # Arbitrary properties can be defined, e.g. "foo :bar" results in a top-level "foo":"bar" in the style
    def respond_to_missing?(*)
      true
    end

    # Set a property, e.g. 'bearing 29'
    def method_missing(method_sym, *args)
      @__impl.add_property(method_sym, *args)
    end
  end
end
