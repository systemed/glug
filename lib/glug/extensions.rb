require 'chroma'
class Integer
	def chroma_hex(op,p)
		("#"+to_s(16).rjust(6,'0')).paint.send(op,p).to_hex
	end
	def chroma(op,p)
		chroma_hex(op,p).gsub('#','0x').to_i(16)
	end
	def to_hex_color
		'#' + to_s(16).rjust(6,'0')
	end
end
