# frozen_string_literal: true

module Glug
  # Defines the methods available to the DSL
  class LayerDSL
    def initialize(impl)
      @__impl = impl
    end

    def literal(*args)
      @__impl.literal(*args)
    end

    def current_value(key)
      @__impl.current_value(key)
    end

    def on(*args, &block)
      @__impl.on(*args, &block)
    end

    def cascade(*args, &block)
      @__impl.cascade(*args, &block)
    end

    def uncascaded(*args)
      @__impl.uncascaded(*args)
    end

    def filter(*args)
      @__impl.filter(*args)
    end

    def id(name)
      @__impl.id(name)
    end

    def suppress
      @__impl.suppress
    end

    def any
      @__impl.any
    end

    def all
      @__impl.all
    end

    def respond_to_missing?(*)
      true
    end

    def method_missing(method_sym, *arguments)
      @__impl.add_property(method_sym, *arguments)
    end
  end
end
