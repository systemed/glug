module Glug # :nodoc:
	class Expression
		attr_accessor :list

		SUBSTITUTIONS = {
			string_format: "format",	# synonyms for Ruby reserved words
			is_in: "in",				#  |
			when_case: "case",			#  |
			add: "+",
			subtract: "-",
			multiply: "*",
			divide: "/",
			modulo: "%",
			power: "^",
			not: "!",
			is: "==",
			is_not: "!=",
			lt: "<", lte: "<=",
			gt: ">", gte: ">="
		}
			

		def initialize(block)
			@block = block
		end
		def encode
			instance_eval(&@block)
		end

		# Convenience so we can write literal(1,2,3) rather than literal([1,2,3])
		def literal(*args)
			if args.length==1 && args[0].is_a?(Hash)
				# Hashes - literal(frog: 1, bill: 2)
				["literal",args[0]]
			else
				# Arrays - literal(1,2,3)
				["literal",args]
			end
		end

		def method_missing(method_sym, *arguments)
			# _Name is a synonym for ['get','Name']
			if method_sym.to_s=~/^_(.+)/ && arguments.empty? then return ["get",$1] end
			# Substitute synonyms for Ruby reserved words
			method_sym = SUBSTITUTIONS[method_sym] || method_sym.to_s.gsub('_','-')
			puts "DataDriven method_missing: #{method_sym} with #{arguments}"
			[method_sym].concat(arguments)
		end
	end
end
