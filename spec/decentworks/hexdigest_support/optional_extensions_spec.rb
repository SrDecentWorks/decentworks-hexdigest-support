# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Decentworks::HexdigestSupport::OptionalExtensions do
  describe ".apply!" do
    # spec_helperがactive_support経由でdate / setを読み込むため、gemの読み込み時点で適用済み
    it "Setに#to_hexdigest_sourceを定義する" do
      expect(::Set.instance_method(:to_hexdigest_source).owner).to eq ::Set
    end

    it "Dateに#to_hexdigest_sourceを定義する" do
      expect(::Date.instance_method(:to_hexdigest_source).owner).to eq ::Date
    end

    it "DateTimeに#to_hexdigest_sourceを定義する" do
      expect(::DateTime.instance_method(:to_hexdigest_source).owner).to eq ::DateTime
    end

    it "何度呼んでもダイジェストが変わらない" do
      before_digest = ::Date.new(2026, 8, 13).to_hexdigest

      described_class.apply!
      described_class.apply!

      expect(::Date.new(2026, 8, 13).to_hexdigest).to eq before_digest
    end
  end
end
