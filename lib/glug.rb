require 'json'
require 'neatjson'

module Glug # :nodoc:

	# -----	Subscriptable
	#       allows us to create conditions with syntax
	#         any[(highway=='primary'),(highway=='trunk')]

	class Subscriptable
		def initialize(type)
			@type=type
		end
		def [](*arguments)
			Condition.new.from_list(@type, arguments)
		end
	end

	# -----	Condition
	#       represents a Mapbox GL filter of the form [operator, key, value] (etc.)
	#       can be merged with other conditions via the & and | operators

	class Condition
		attr_accessor :values, :operator
		def initialize
			@values=[]
		end
		def from_key(operator, key, list)
			@operator = operator
			@values = [key].concat(list)
			self
		end
		def from_list(operator, list)
			@operator = operator
			@values = list
			self
		end
		def &(cond); merge(:all,cond) end
		def |(cond); merge(:any,cond) end
		def merge(op,cond)
			if cond.nil?
				self
			elsif @operator==op
				Condition.new.from_list(op, @values + [cond])
#				@values << cond; self
			elsif cond.operator==op
				Condition.new.from_list(op, [self] + cond.values)
#				cond.values << self; cond
			else
				Condition.new.from_list(op, [self, cond])
			end
		end
		# Encode into an array for Mapbox GL JSON (recursive)
		def encode
			[@operator.to_s, *@values.map { |v| v.is_a?(Condition) ? v.encode : v } ]
		end
		def to_s; "<Condition #{@operator} #{@values}>" end
	end

	# -----	Stylesheet
	#       the main document object

	class Stylesheet
		attr_accessor :sources, :kv, :refs

		def initialize(&block)
			@sources = {}
			@kv = {}
			@layers = []
			@refs = {}
			instance_eval(&block)
		end

		# Set a property, e.g. 'bearing 29'
		def method_missing(method_sym, *arguments)
			@kv[method_sym] = arguments[0]
		end

		# Add a source 
		def source(source_name, opts={})
			@sources[source_name] = opts
		end

		# Add a layer
		# creates a new Layer object using the block supplied
		def layer(id, opts={}, &block)
			r = Layer.new(self, :id=>id, :kv=>opts)
			@layers << r
			r.instance_eval(&block)
		end

		# Assemble into Mapbox GL JSON format
		def to_hash
			out = @kv.dup
			out['sources'] = @sources.dup
			out['sources'].each { |k,v| v.delete(:default); out['sources'][k] = v }
			out['layers'] = @layers.select { |r| r.write? }.collect { |r| r.to_hash }.compact
			out
		end
		def to_json(*args); JSON.neat_generate(to_hash) end

		# Setter for Layer to add sublayers
		def _add_layer(layer)
			@layers << layer
		end
	end

	# -----	OSMKey
	#       enables us to write "population<30000" and have it magically converted into a Condition

	class OSMKey
		def initialize(k)
			@k=k
		end
		def is(*args); Condition.new.from_key(:==,@k,args) end
		def ==(*args); Condition.new.from_key(:==,@k,args) end
		def !=(*args); Condition.new.from_key(:!=,@k,args) end
		def  <(*args); Condition.new.from_key(:< ,@k,args) end
		def  >(*args); Condition.new.from_key(:> ,@k,args) end
		def <=(*args); Condition.new.from_key(:<=,@k,args) end
		def >=(*args); Condition.new.from_key(:>=,@k,args) end
		def in(*args); Condition.new.from_key(:in,@k,args.flatten) end
		def not_in(*args); Condition.new.from_key('!in',@k,args.flatten) end
	end

	# -----	Layer
	#       a layer in an Mapbox GL style
	#       this is where most of the hard work happens, including 'method_missing' and 'on'
	#         calls to provide the grammar

	class Layer

		# Mapbox GL properties (as distinct from OSM keys)
		LAYOUT    = [ :visibility,
		              :line_cap, :line_join, :line_miter_limit, :line_round_limit, 
		              :symbol_placement, :symbol_spacing, :symbol_avoid_edges,
		              :icon_allow_overlap, :icon_ignore_placement, :icon_optional, :icon_rotation_alignment, :icon_size,
		              :icon_image, :icon_rotate, :icon_padding, :icon_keep_upright, :icon_offset, :icon_text_fit, :icon_text_fit_padding,
		              :text_rotation_alignment, :text_field, :text_font, :text_size, :text_max_width, :text_line_height,
		              :text_letter_spacing, :text_justify, :text_anchor, :text_max_angle, :text_rotate, :text_padding,
		              :text_keep_upright, :text_transform, :text_offset, :text_allow_overlap, :text_ignore_placement, :text_optional ]
		PAINT     = [ :background_color, :background_pattern, :background_opacity,
		              :fill_antialias, :fill_opacity, :fill_color, :fill_outline_color, :fill_translate, :fill_translate_anchor, :fill_pattern,
		              :line_opacity, :line_color, :line_translate, :line_translate_anchor, :line_width, :line_gap_width,
		              :line_blur, :line_dasharray, :line_pattern,
		              :icon_opacity, :icon_color, :icon_halo_color, :icon_halo_width, :icon_halo_blur, :icon_translate, :icon_translate_anchor,
		              :text_opacity, :text_color, :text_halo_color, :text_halo_width, :text_halo_blur, :text_translate, :text_translate_anchor,
		              :raster_opacity, :raster_hue_rotate, :raster_brightness_min, :raster_brightness_max, :raster_saturation, :raster_contrast, :raster_fade_duration,
		              :circle_radius, :circle_color, :circle_blur, :circle_opacity, :circle_translate, :circle_translate_anchor ]
		TOP_LEVEL = [ :metadata, :zoom, :interactive ]
		HIDDEN    = [ :ref, :source, :source_layer, :id, :type, :filter, :layout, :paint ]	# top level, not settable by commands

		# Shared properties that can be recalled by using a 'ref' 
		REF_PROPERTIES = ['type', 'source', 'source-layer', 'minzoom', 'maxzoom', 'filter', 'layout']

		attr_accessor :kv				# key-value pairs for layout, paint, and top level
		attr_accessor :condition		# filter condition
		attr_accessor :stylesheet		# parent stylesheet object

		def initialize(stylesheet, args={})
			@stylesheet = stylesheet
			@condition = args[:condition]
			@kv = args[:kv] || {}
			@kv[:id] = args[:id]
			if args[:zoom] then @kv[:zoom]=args[:zoom] end

			@type = nil							# auto-detected layer type
			@write = true						# write this layer out, or has it been suppressed?
			@cascade_cond = nil					# are we currently evaluating a cascade directive?
			@cascades = args[:cascades] || []	# cascade list to apply to all subsequent layers
			@uncascaded = nil					# condition to add to non-cascaded layers

			@kv[:source] ||= stylesheet.sources.find {|k,v| v[:default] }[0]
			@kv[:source_layer] ||= args[:id]
			@child_num = 0				# incremented sublayer suffix
		end

		# Handle all missing 'method' calls
		# If we can match it to a Mapbox GL property, it's an assignment:
		# otherwise it's an OSM key
		def method_missing(method_sym, *arguments)
			if LAYOUT.include?(method_sym) || PAINT.include?(method_sym) || TOP_LEVEL.include?(method_sym)
				v = arguments.length==1 ? arguments[0] : arguments
				if v.is_a?(Proc) then v=v.call(@kv[method_sym]) end
				if @cascade_cond.nil?
					@kv[method_sym] = v
				else
					_add_cascade_condition(method_sym, v)
				end
			else
				return OSMKey.new(method_sym.to_s)
			end
		end

		# Add a sublayer with an additional filter
		def on(*args, &block)
			@child_num+=1
			r = Layer.new(@stylesheet,
					:id => "#{@kv[:id]}__#{@child_num}".to_sym,
					:kv => @kv.dup, :cascades => @cascades.dup)

			# Set zoom level
			if args[0].is_a?(Range) || args[0].is_a?(Fixnum)
				r.kv[:zoom] = args.shift
			end

			# Set condition
			sub_cond = nil
			if args.empty?
				sub_cond = @condition						# just inherit parent layer's condition
			else
				sub_cond = (args.length==1) ? args[0] : Condition.new.from_list(:any,args)
				sub_cond = nilsafe_merge(sub_cond, @condition)
			end
			r._set_filter(nilsafe_merge(sub_cond, @uncascaded))
			r.instance_eval(&block)
			@stylesheet._add_layer(r)

			# Create cascaded layers
			child_chr='a'
			@cascades.each do |c|
				c_cond, c_kv = c
				l = Layer.new(@stylesheet, :id=>"#{r.kv[:id]}__#{child_chr}", :kv=>r.kv.dup)
				l._set_filter(nilsafe_merge(sub_cond, c_cond))
				l.kv.merge!(c_kv)
				@stylesheet._add_layer(l)
				child_chr.next!
			end
		end
		
		# Short-form key constructor - for reserved words
		def tag(k)
			OSMKey.new(k)
		end

		# Nil-safe merge
		def nilsafe_merge(a,b)
			a.nil? ? b : (a & b)
		end

		# Add a cascading condition
		def cascade(*args, &block)
			cond = (args.length==1) ? args[0] : Condition.new.from_list(:any,args)
			@cascade_cond = cond
			self.instance_eval(&block)
			@cascade_cond = nil
		end
		def _add_cascade_condition(k, v)
			if @cascades.length>0 && @cascades[-1][0].to_s==@cascade_cond.to_s
				@cascades[-1][1][k]=v
			else
				@cascades << [@cascade_cond, { k=>v }]
			end
		end
		def uncascaded(*args)
			cond = case args.length
				when 0; nil
				when 1; args[0]
				else; Condition.new.from_list(:any,args)
			end
			@uncascaded = cond
		end

		# Setters for @condition (making sure we copy when inheriting)
		def filter(*args)
			_set_filter(args.length==1 ? args[0] : Condition.new.from_list(:any,args))
		end
		def _set_filter(condition)
			@condition = condition.nil? ? nil : condition.dup
		end

		# Set layer name
		def id(name)
			@kv[:id] = name
		end
		
		# Suppress output of this layer
		def suppress; @write = false end
		def write?; @write end

		# Square-bracket filters (any[...], all[...], none[...])
		def any ; return Subscriptable.new(:any ) end
		def all ; return Subscriptable.new(:all ) end
		def none; return Subscriptable.new(:none) end

		# Deduce 'type' attribute from style attributes
		def set_type_from(s)
			return unless s.include?('-')
			t = s.split('-')[0].to_sym
			if t==:icon || t==:text then t=:symbol end
			if @type && @type!=t then raise "Attribute #{s} conflicts with deduced type #{@type} in layer #{@kv[:id]}" end
			@type=t
		end

		# Create a Mapbox GL-format hash from a layer definition
		def to_hash
			hash = { :layout=> {}, :paint => {} }

			# Assign key/values to correct place
			@kv.each do |k,v|
				s = k.to_s.gsub('_','-')
				if s.include?('-color') && v.is_a?(Fixnum) then v = "#%06x" % v end

				if LAYOUT.include?(k)
					hash[:layout][s]=v
					set_type_from s
				elsif PAINT.include?(k)
					hash[:paint][s]=v
					set_type_from s
				elsif TOP_LEVEL.include?(k) || HIDDEN.include?(k)
					hash[s]=v
				else raise "#{s} isn't a recognised layer attribute"
				end
			end

			hash['type'] = @type
			if @condition then hash['filter'] = @condition.encode end

			# Convert zoom level
			if (v=hash['zoom'])
				hash['minzoom'] = v.is_a?(Range) ? v.first : v
				hash['maxzoom'] = v.is_a?(Range) ? v.last  : v
				hash.delete('zoom')
			end

			# See if we can reuse an earlier layer's properties
			mk = ref_key(hash)
			if stylesheet.refs[mk]
				REF_PROPERTIES.each { |k| hash.delete(k) }
				hash['ref'] = stylesheet.refs[mk]
			else
				stylesheet.refs[mk] = hash['id']
			end

			if hash[:layout].empty? && hash[:paint].empty?
				nil
			else
				hash.delete(:layout) if hash[:layout].empty?
				hash.delete(:paint) if hash[:paint].empty?
				hash
			end
		end

		# Key to identify matching layer properties (slow but...)
		def ref_key(hash)
			(REF_PROPERTIES.collect { |k| hash[k] } ).to_json
		end
	end
end
