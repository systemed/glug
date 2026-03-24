# frozen_string_literal: true

module Glug
  # the main document object
  class Stylesheet
    attr_accessor :sources, :kv, :base_dir, :params, :dsl

    def initialize(base_dir: nil, params: nil, &block)
      @sources = {}
      @kv = {}
      @layers = []
      @layer_order = nil
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

    def layer_order(order)
      @layer_order = order
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
      out['layers'] = ordered_layers.collect(&:to_hash).compact
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

    private

    def ordered_layers
      writable = @layers.select(&:write?)
      return writable unless @layer_order

      order_strings = @layer_order.map(&:to_s)

      # Include sublayers automatically if parent layer is included
      groups = Hash.new { |h, k| h[k] = [] }
      writable.each do |layer|
        lid = layer.kv[:id].to_s
        group = find_order_group(lid, order_strings)
        groups[group] << layer if group
      end

      order_strings.flat_map { |entry| groups[entry] || [] }
    end

    def find_order_group(layer_id, order_strings)
      return layer_id if order_strings.include?(layer_id)

      # Find the longest order entry that is a prefix of this layer's ID
      best = nil
      order_strings.each do |entry|
        best = entry if layer_id.start_with?("#{entry}__") && (best.nil? || entry.length > best.length)
      end

      # If a parent matched, only auto-include when no sibling sublayer
      # is explicitly in the order (explicit reference opts into manual control)
      if best
        order_strings.each do |entry|
          return nil if entry.start_with?("#{best}__")
        end
      end

      best
    end
  end
end
