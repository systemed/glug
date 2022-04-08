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

	# -----	Condition
	#       represents a GL filter of the form [operator, key, value] (etc.)
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
			elsif cond.operator==op
				Condition.new.from_list(op, [self] + cond.values)
			else
				Condition.new.from_list(op, [self, cond])
			end
		end
		# Encode into an array for GL JSON (recursive)
		def encode
			[@operator.to_s, *@values.map { |v| v.is_a?(Condition) ? v.encode : v } ]
		end
		def to_s; "<Condition #{@operator} #{@values}>" end
	end
end
