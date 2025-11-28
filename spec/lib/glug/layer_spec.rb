# frozen_string_literal: true

describe Glug::Layer do
  describe 'zoom levels' do
    it 'treats an integer as both min and max' do
      stylesheet = Glug::Stylesheet.new do
        source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
      end
      l = described_class.new(stylesheet, { zoom: 7 })
      l.line_width 1

      h = l.to_hash
      expect(h['minzoom']).to be(7)
      expect(h['maxzoom']).to be(7)
    end

    it 'splits a range into min and max' do
      stylesheet = Glug::Stylesheet.new do
        source :osm_data, type: 'vector', url: 'http://example.com/osm.tilejson', default: true
      end
      l = described_class.new(stylesheet, { zoom: 1..5 })
      l.line_width 1

      h = l.to_hash
      expect(h['minzoom']).to be(1)
      expect(h['maxzoom']).to be(5)
    end
  end
end
