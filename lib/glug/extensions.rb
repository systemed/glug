require 'chroma'
require 'hsluv'

# Colour methods on Integer

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

# Top-level colour generators

def hsluv(h,s,l)
	arr = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h,s*100,l*100))
	(arr[0]*256 + arr[1])*256 + arr[2]
end
def hsl(h,s,l)
	rgb = Chroma::RgbGenerator::FromHslValues.new('hex6',h,s,l).generate[0]
	((rgb.r).to_i*256 + (rgb.g).to_i)*256 + rgb.b.to_i
end
