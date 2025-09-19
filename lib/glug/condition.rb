# frozen_string_literal: true

module Glug # :nodoc:
  # -----	Subscriptable
  #       allows us to create conditions with syntax
  #         any[(highway=='primary'),(highway=='trunk')]
  class Subscriptable
    def initialize(type)
      @type = type
    end

    def [](*arguments)
      Condition.new.from_list(@type, arguments)
    end
  end

  # -----	Condition
  #       represents a GL filter of the form [operator, key, value] (etc.)
  #       can be merged with other conditions via the & and | operators
  class Condition
    attr_accessor :values, :operator

    # GL operators we can't use verbatim (mostly Ruby reserved words)
    SUBSTITUTIONS = {
      string_format: 'format',
      is_in: 'in',
      case_when: 'case',
      _!: '!',
      subtract: '-', divide: '/', pow: '^', # so we can write 'subtract(100,height)'
      feature_id: 'id' # Glug already uses 'id'
    }.freeze

    # GL operators that make sense to use as suffixed dot methods
    DOT_METHODS = %i[
      array boolean string_format image number number_format object string
      to_boolean to_color to_number to_string typeof
      length slice match
      downcase upcase is_supported_script to_rgba
      abs acos asin atan ceil cos floor ln log10 log2 round sin sqrt tan
    ].freeze

    def is(*args)
      Condition.new.from_key(:==, self, args)
    end

    def ==(*args)
      Condition.new.from_key(:==, self, args)
    end

    def !=(*args)
      Condition.new.from_key(:!=, self, args)
    end

    def <(*args)
      Condition.new.from_key(:<, self, args)
    end

    def >(*args)
      Condition.new.from_key(:>, self, args)
    end

    def <=(*args)
      Condition.new.from_key(:<=, self, args)
    end

    def >=(*args)
      Condition.new.from_key(:>=, self, args)
    end

    def %(*args)
      Condition.new.from_key(:%, self, args)
    end

    def +(*args)
      Condition.new.from_key(:+, self, args)
    end

    def -(*args)
      Condition.new.from_key(:-, self, args)
    end

    def *(*args)
      Condition.new.from_key(:*, self, args)
    end

    def /(*args)
      Condition.new.from_key(:/, self, args)
    end

    def **(*args)
      Condition.new.from_key(:^, self, args)
    end

    def in(*args)
      Condition.new.from_key(:in, self, [[:literal, args.flatten]])
    end

    def [](*args)
      Condition.new.from_key(:at, args[0], [self])
    end

    def coerce(other)
      [Condition.new.just_value(other), self]
    end

    def initialize
      @values = []
    end

    def from_key(operator, key, list)
      @operator = SUBSTITUTIONS[operator] || operator.to_s.gsub('_', '-')
      @values = [key].concat(list)
      self
    end

    def from_list(operator, list)
      @operator = SUBSTITUTIONS[operator] || operator.to_s.gsub('_', '-')
      @values = list
      self
    end

    def just_value(val)
      @operator = nil
      @values = [val]
      self
    end

    def &(other)
      merge(:all, other)
    end

    def |(other)
      merge(:any, other)
    end

    def merge(op, cond)
      if cond.nil?
        self
      elsif @operator == op
        Condition.new.from_list(op, @values + [cond])
      elsif cond.operator == op
        Condition.new.from_list(op, [self] + cond.values)
      else
        Condition.new.from_list(op, [self, cond])
      end
    end

    def <<(cond)
      @values << cond.encode
      self
    end

    def respond_to_missing?(method_sym, include_private)
      DOT_METHODS.include?(method_sym) || super
    end

    # Support dot access for most methods
    def method_missing(method_sym, *args)
      if DOT_METHODS.include?(method_sym)
        Condition.new.from_key(method_sym, self, args)
      else
        super
      end
    end

    # Encode into an array for GL JSON (recursive)
    def encode
      transform_underscores
      values = @values.map { |v| v.is_a?(Condition) ? v.encode : v }
      @operator.nil? ? values[0] : [@operator.to_s, *values]
    end

    def to_json(opts)
      encode.to_json(opts)
    end

    def to_s
      "<Condition #{@operator} #{@values}>"
    end

    # Transform nested { font_scale: 0.8 } to { "font-scale"=>0.8 }
    def transform_underscores
      @values.map! do |v|
        if v.is_a?(Hash)
          new_hash = {}
          v.each { |hk, hv| new_hash[hk.is_a?(Symbol) ? hk.to_s.gsub('_', '-') : hk] = hv }
          new_hash
        else
          v
        end
      end
    end
  end
end
