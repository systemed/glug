# frozen_string_literal: true

require 'chroma'
require 'hsluv'

module Chroma
  # Add hsluv versions of the color functions to chroma
  class Color
    def darkenp(amount = 10)
      h, s, l = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      new_l = [l - amount, 0].max
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, s, new_l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end

    def lightenp(amount = 10)
      h, s, l = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      new_l = [l + amount, 100].min
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, s, new_l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end
  end
end
