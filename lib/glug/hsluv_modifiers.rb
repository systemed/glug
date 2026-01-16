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

    def saturatep(amount = 10)
      h, s, l = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      new_s = [s + amount, 100].min
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, new_s, l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end

    def desaturatep(amount = 10)
      h, s, l = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      new_s = [s - amount, 0].max
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, new_s, l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end

    def greyscalep
      h, _s, l = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, 0, l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end
    alias grayscalep greyscalep

    def spinp(amount = 0)
      h, s, l = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      new_h = (h + amount) % 360
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(new_h, s, l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end

    def mixp(other, weight = 50)
      other = other.paint if other.is_a?(String)
      p = weight / 100.0

      h1, s1, l1 = Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
      h2, s2, l2 = Hsluv.rgb_to_hsluv(other.rgb.r / 255.0, other.rgb.g / 255.0, other.rgb.b / 255.0)

      # Interpolate hue on the shortest path around the color wheel
      h_diff = h2 - h1
      h_diff -= 360 if h_diff > 180
      h_diff += 360 if h_diff < -180
      new_h = (h1 + h_diff * (1 - p)) % 360

      new_s = s1 * p + s2 * (1 - p)
      new_l = l1 * p + l2 * (1 - p)

      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(new_h, new_s, new_l))
      Chroma.paint("rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end
  end
end
