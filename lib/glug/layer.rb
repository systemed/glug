module Glug # :nodoc:

	# -----	Layer
	#       a layer in a GL style
	#       this is where most of the hard work happens, including 'method_missing' and 'on' calls to provide the grammar

	class Layer

		# GL properties (as distinct from OSM keys)
		LAYOUT    = [ :visibility,
		              :fill_sort_key,
		              :circle_sort_key,	
		              :line_cap, :line_join, :line_miter_limit, :line_round_limit, :line_sort_key,
		              :symbol_placement, :symbol_spacing, :symbol_avoid_edges, :symbol_sort_key, :symbol_z_order,
		              :icon_allow_overlap, :icon_overlap, :icon_ignore_placement, :icon_optional, :icon_rotation_alignment, :icon_size, :icon_text_fit,
		              :icon_text_fit_padding, :icon_image, :icon_rotate, :icon_padding, :icon_keep_upright, :icon_offset, :icon_anchor, :icon_pitch_alignment,
		              :text_pitch_alignment, :text_rotation_alignment, :text_field, :text_font, :text_size, :text_max_width, :text_line_height,
		              :text_letter_spacing, :text_justify, :text_radial_offset, :text_variable_anchor, :text_variable_anchor_offset,
		              :text_anchor, :text_max_angle, :text_writing_mode, :text_rotate, :text_padding,
		              :text_keep_upright, :text_transform, :text_offset, :text_allow_overlap, :text_overlap, :text_ignore_placement, :text_optional ]
		PAINT     = [ :background_color, :background_pattern, :background_opacity,
		              :fill_antialias, :fill_opacity, :fill_color, :fill_outline_color, :fill_translate, :fill_translate_anchor, :fill_pattern,
		              :circle_radius, :circle_color, :circle_blur, :circle_opacity, :circle_translate, :circle_translate_anchor,
		              :circle_pitch_scale, :circle_pitch_alignment, :circle_stroke_width, :circle_stroke_color, :circle_stroke_opacity,
		              :heatmap_radius, :heatmap_weight, :heatmap_intensity, :heatmap_color, :heatmap_opacity,
		              :fill_extrusion_opacity, :fill_extrusion_color, :fill_extrusion_translate, :fill_extrusion_translate_anchor,
		              :fill_extrusion_pattern, :fill_extrusion_height, :fill_extrusion_base, :fill_extrusion_vertical_gradient,
		              :line_opacity, :line_color, :line_translate, :line_translate_anchor, :line_width, :line_gap_width, :line_offset,
		              :line_blur, :line_dasharray, :line_pattern, :line_gradient,
		              :icon_opacity, :icon_color, :icon_halo_color, :icon_halo_width, :icon_halo_blur, :icon_translate, :icon_translate_anchor,
		              :text_opacity, :text_color, :text_halo_color, :text_halo_width, :text_halo_blur, :text_translate, :text_translate_anchor,
		              :raster_opacity, :raster_hue_rotate, :raster_brightness_min, :raster_brightness_max,
		              :raster_saturation, :raster_contrast, :raster_resampling, :raster_fade_duration,
		              :hillshade_illumination_direction, :hillshade_illumination_direction, :hillshade_illumination_altitude, :hillshade_illumination_anchor,
		              :hillshade_exaggeration, :hillshade_shadow_color, :hillshade_highlight_color, :hillshade_accent_color, :hillshade_method,
		              :color_relief_opacity, :color_relief_color ]
		TOP_LEVEL = [ :metadata, :zoom, :interactive ]
<<<<<<< HEAD
		HIDDEN    = [ :ref, :source, :source_layer, :id, :type, :filter, :layout, :paint ]	# top level, not settable by commands
		EXPRESSIONS=[ :let, :var,
		              :literal, :array, :typeof, :string, :number, :boolean, :object, :collator,
		              :string_format, :image, :number_format, :to_string, :to_number, :to_boolean, :to_color,
		              :at, :is_in, :index_of, :slice, :global_state, :get, :has, :length,
		              :case_when, :match, :coalesce, :all, :any, :_!, :within,
		              :step, :interpolate, :interpolate_hcl, :interpolate_lab,
		              :ln2, :pi, :e, :subtract, :divide, :pow, :sqrt, :log10, :ln, :log2, :sin, :cos, :tan,
		              :asin, :acos, :atan, :min, :max, :round, :abs, :ceil, :floor, :distance,
		              :to_rgba, :rgb, :rgba,
		              :properties, :feature_state, :geometry_type, :feature_id, :line_progress, :accumulated,
		              :zoom,
		              :heatmap_density,
		              :elevation,
		              :is_supported_script, :upcase, :downcase, :concat, :resolved_locale,
		              # Mapbox GL only
		              :distance_from_center, :pitch ]
||||||| parent of 075255c (Stop creating ref layers when layers share properties)
		HIDDEN    = [ :ref, :source, :source_layer, :id, :type, :filter, :layout, :paint ]	# top level, not settable by commands
		EXPRESSIONS=[ :array, :boolean, :collator, :string_format, :image, :literal, :number,
		              :number_format, :object, :string, :to_boolean, :to_color, :to_number, :to_string,
		              :typeof, :accumulated, :feature_state, :geometry_type, :feature_id,
		              :line_progress, :properties, :at, :get, :has, :is_in, :index_of,
		              :length, :slice,
					  :all, :any, :case_when, :coalesce, :match, :within,
					  :interpolate, :interpolate_hcl, :interpolate_lab, :step,
					  :let, :var, :concat, :downcase, :upcase,
					  :is_supported_script, :resolved_locale,
					  :rgb, :rgba, :to_rgba, :abs, :acos, :asin, :atan, :ceil, :cos, :distance,
					  :e, :floor, :ln, :ln2, :log10, :log2, :max, :min, :pi, :round, :sin, :sqrt, :tan,
					  :distance_from_center, :pitch, :zoom, :heatmap_density,
					  :subtract, :divide, :pow, :_! ]
=======
		HIDDEN    = [ :source, :source_layer, :id, :type, :filter, :layout, :paint ]	# top level, not settable by commands
		EXPRESSIONS=[ :array, :boolean, :collator, :string_format, :image, :literal, :number,
		              :number_format, :object, :string, :to_boolean, :to_color, :to_number, :to_string,
		              :typeof, :accumulated, :feature_state, :geometry_type, :feature_id,
		              :line_progress, :properties, :at, :get, :has, :is_in, :index_of,
		              :length, :slice,
					  :all, :any, :case_when, :coalesce, :match, :within,
					  :interpolate, :interpolate_hcl, :interpolate_lab, :step,
					  :let, :var, :concat, :downcase, :upcase,
					  :is_supported_script, :resolved_locale,
					  :rgb, :rgba, :to_rgba, :abs, :acos, :asin, :atan, :ceil, :cos, :distance,
					  :e, :floor, :ln, :ln2, :log10, :log2, :max, :min, :pi, :round, :sin, :sqrt, :tan,
					  :distance_from_center, :pitch, :zoom, :heatmap_density,
					  :subtract, :divide, :pow, :_! ]
>>>>>>> 075255c (Stop creating ref layers when layers share properties)

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
			@kv[:source_layer] ||= args[:id] if stylesheet.sources[@kv[:source]][:type]=="vector"
			@child_num = 0				# incremented sublayer suffix
		end

		# Handle all missing 'method' calls
		# If we can match it to a GL property, it's an assignment:
		# otherwise it's an OSM key
		def method_missing(method_sym, *arguments)
			if EXPRESSIONS.include?(method_sym)
				return Condition.new.from_list(method_sym, arguments)
			elsif LAYOUT.include?(method_sym) || PAINT.include?(method_sym) || TOP_LEVEL.include?(method_sym)
				v = arguments.length==1 ? arguments[0] : arguments
				if v.is_a?(Proc) then v=v.call(@kv[method_sym]) end
				if @cascade_cond.nil?
					@kv[method_sym] = v
				else
					_add_cascade_condition(method_sym, v)
				end
			else
				return Condition.new.from_list("get", [method_sym])
			end
		end

		# Convenience so we can write literal(1,2,3) rather than literal([1,2,3])
		def literal(*args)
			if args.length==1 && args[0].is_a?(Hash)
				# Hashes - literal(frog: 1, bill: 2)
				Condition.new.from_list(:literal, [args[0]])
			else
				# Arrays - literal(1,2,3)
				Condition.new.from_list(:literal, [args])
			end
		end

		# Return a current value from @kv
		# This allows us to do: line_width current_value(:line_width)/2.0
		def current_value(key)
			@kv[key]
		end

		# Add a sublayer with an additional filter
		def on(*args, &block)
			@child_num+=1
			r = Layer.new(@stylesheet,
					:id => "#{@kv[:id]}__#{@child_num}".to_sym,
					:kv => @kv.dup, :cascades => @cascades.dup)

			# Set zoom level
			if args[0].is_a?(Range) || args[0].is_a?(Integer)
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

		# Square-bracket filters (any[...], all[...])
		def any ; return Subscriptable.new(:any ) end
		def all ; return Subscriptable.new(:all ) end

		# Deduce 'type' attribute from style attributes
		def set_type_from(s)
			return unless s.include?('-')
			t = (s=~/^fill-extrusion/ ? "fill-extrusion" : s.split('-')[0]).to_sym
			if t==:icon || t==:text then t=:symbol end
			if @type && @type!=t then raise "Attribute #{s} conflicts with deduced type #{@type} in layer #{@kv[:id]}" end
			@type=t
		end

		# Create a GL-format hash from a layer definition
		def to_hash
			hash = { :layout=> {}, :paint => {} }

			# Assign key/values to correct place
			@kv.each do |k,v|
				s = k.to_s.gsub('_','-')
				if s.include?('-color') && v.is_a?(Integer) then v = "#%06x" % v end
				if v.respond_to?(:encode) then v=v.encode end

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

			if hash[:layout].empty? && hash[:paint].empty?
				nil
			else
				hash.delete(:layout) if hash[:layout].empty?
				hash.delete(:paint) if hash[:paint].empty?
				hash
			end
		end

	end # class Layer
end # module Glug
