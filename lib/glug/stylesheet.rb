# frozen_string_literal: true

module Glug
  # the main document object
  class Stylesheet
    attr_accessor :sources, :kv, :base_dir, :params

    def initialize(base_dir: nil, params: nil, &block)
      @sources = {}
      @kv = {}
      @layers = []
      @base_dir = base_dir || ''
      @params = params || {}
      @dsl = StylesheetDSL.new(self)
      @dsl.instance_eval(&block)
    end

    # Set a property, e.g. 'bearing 29'
    def add_property(method_sym, *args)
      @kv[method_sym] = args[0]
    end

    # Add a source
    def source(source_name, opts = {})
      @sources[source_name] = opts
    end

    # Add a layer
    # creates a new Layer object using the block supplied
    def layer(id, opts = {}, &block)
      r = Layer.new(self, id: id, kv: opts)
      @layers << r
      r.dsl_eval(&block)
    end

    # Assemble into GL JSON format
    def to_hash
      out = @kv.dup
      out['sources'] = @sources.dup
      out['sources'].each do |k, v|
        v.delete(:default)
        out['sources'][k] = v
      end
      out['layers'] = @layers.select(&:write?).collect(&:to_hash).compact
      out
    end

    def to_json(*_args)
      JSON.neat_generate(to_hash)
    end

    # Setter for Layer to add sublayers
    def _add_layer(layer)
      @layers << layer
    end

    # Load file
    def include_file(filename)
      @dsl.instance_eval(File.read(File.join(@base_dir, filename)))
    end
  end
end
