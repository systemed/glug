# frozen_string_literal: true

require 'chroma'
require 'hsluv'

# Colour methods on Integer
class Integer
  # rubocop:disable Style/StringConcatenation, Naming/MethodParameterName
  def chroma_hex(op, p = nil)
    color = ('#' + to_s(16).rjust(6, '0')).paint
    (p.nil? ? color.send(op) : color.send(op, p)).to_hex
  end

  def chroma(op, p = nil)
    chroma_hex(op, p).gsub('#', '0x').to_i(16)
  end

  def to_hex_color
    '#' + to_s(16).rjust(6, '0')
  end
  # rubocop:enable Style/StringConcatenation, Naming/MethodParameterName
end

# Top-level colour generators

def hsluv(h, s, l) # rubocop:disable Naming/MethodParameterName
  arr = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, s * 100, l * 100))
  (arr[0] * 256 + arr[1]) * 256 + arr[2]
end

def hsl(h, s, l) # rubocop:disable Naming/MethodParameterName
  rgb = Chroma::RgbGenerator::FromHslValues.new('hex6', h, s, l).generate[0]
  (rgb.r.to_i * 256 + rgb.g.to_i) * 256 + rgb.b.to_i
end
