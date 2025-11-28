# frozen_string_literal: true

describe Glug::Stylesheet do
  it 'processes a basic stylesheet' do
    json = described_class.new do
      version 8
      center [0.5, 53]
    end.to_json
    expect(json).to eql('{"version":8,"center":[0.5,53],"sources":{},"layers":[]}')
  end

  it 'processes the example stylesheet' do
    json = described_class.new do
      version 8
      name 'My first stylesheet'
      source :shortbread, type: 'vector', url: 'https://vector.openstreetmap.org/shortbread_v1/tilejson.json'

      layer(:roads, zoom: 10..13, source: :shortbread) do
        line_width 6
        line_color match(highway,
                         'motorway', :blue,
                         'trunk', :green,
                         'primary', :red,
                         'secondary', :orange,
                         0x888888)
      end
    end.to_json
    expect(json).to eq(<<~DOC
      {
        "version":8,
        "name":"My first stylesheet",
        "sources":{
          "shortbread":{
            "type":"vector",
            "url":"https://vector.openstreetmap.org/shortbread_v1/tilejson.json"
          }
        },
        "layers":[
          {
            "paint":{
              "line-width":6,
              "line-color":[
                "match",
                ["get","highway"],
                "motorway",
                "blue",
                "trunk",
                "green",
                "primary",
                "red",
                "secondary",
                "orange",
                8947848
              ]
            },
            "source":"shortbread",
            "id":"roads",
            "source-layer":"roads",
            "type":"line",
            "minzoom":10,
            "maxzoom":13
          }
        ]
      }
    DOC
    .strip)
  end
end
