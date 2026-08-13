# frozen_string_literal: true

RSpec.describe Decentworks::HexdigestSupport do
  it "has a version number" do
    expect(Decentworks::HexdigestSupport::VERSION).not_to be_nil
  end

  it "セマンティックバージョニングの形式である" do
    expect(Decentworks::HexdigestSupport::VERSION).to match(/\A\d+\.\d+\.\d+\z/)
  end
end
