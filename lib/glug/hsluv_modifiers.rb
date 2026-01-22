# frozen_string_literal: true

require 'chroma'
require 'hsluv'

module Chroma
  # Add hsluv versions of the color functions to chroma
  class Color
    def darkenp(amount = 10)
      h, s, l = to_hsluv
      l = [l - amount, 0].max
      from_hsluv(h, s, l)
    end

    def lightenp(amount = 10)
      h, s, l = to_hsluv
      l = [l + amount, 100].min
      from_hsluv(h, s, l)
    end

    def saturatep(amount = 10)
      h, s, l = to_hsluv
      s = [s + amount, 100].min
      from_hsluv(h, s, l)
    end

    def desaturatep(amount = 10)
      h, s, l = to_hsluv
      s = [s - amount, 0].max
      from_hsluv(h, s, l)
    end

    def greyscalep
      h, _s, l = to_hsluv
      from_hsluv(h, 0, l)
    end
    alias grayscalep greyscalep

    def spinp(amount = 0)
      h, s, l = to_hsluv
      h = (h + amount) % 360
      from_hsluv(h, s, l)
    end

    def mixp(other, weight = 50)
      other = other.paint if other.is_a?(String)
      p = weight / 100.0

      h1, s1, l1 = to_hsluv
      h2, s2, l2 = other.to_hsluv

      # Interpolate hue on the shortest path around the color wheel
      h_diff = h2 - h1
      h_diff -= 360 if h_diff > 180
      h_diff += 360 if h_diff < -180
      h = (h1 + h_diff * (1 - p)) % 360
      s = s1 * p + s2 * (1 - p)
      l = l1 * p + l2 * (1 - p)

      from_hsluv(h, s, l)
    end

    def to_hsluv
      Hsluv.rgb_to_hsluv(rgb.r / 255.0, rgb.g / 255.0, rgb.b / 255.0)
    end

    def from_hsluv(h, s, l) # rubocop:disable Naming/MethodParameterName
      rgb_values = Hsluv.rgb_prepare(Hsluv.hsluv_to_rgb(h, s, l))
      Chroma.paint(+"rgb(#{rgb_values[0]}, #{rgb_values[1]}, #{rgb_values[2]})")
    end
  end
end
