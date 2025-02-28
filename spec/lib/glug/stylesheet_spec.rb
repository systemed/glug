# frozen_string_literal: true

describe Glug::Stylesheet do
  it 'processes a basic stylesheet' do
    json = described_class.new do
      version 8
      center [0.5, 53]
    end.to_json
    expect(json).to eql('{"version":8,"center":[0.5,53],"sources":{},"layers":[]}')
  end
end
