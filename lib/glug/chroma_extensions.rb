# frozen_string_literal: true

require 'chroma'
require 'hsluv'

module Chroma
  class Color # :nodoc:
    def mix(other, weight = 50)
      other = other.paint if other.is_a?(String)
      p = weight / 100.0

      r = (rgb.r * p + other.rgb.r * (1 - p)).round
      g = (rgb.g * p + other.rgb.g * (1 - p)).round
      b = (rgb.b * p + other.rgb.b * (1 - p)).round

      Chroma.paint("rgb(#{r}, #{g}, #{b})")
    end
  end
end
