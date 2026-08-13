# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::DateTime do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "オフセットを持つ日時の場合" do
      let(:instance) { ::DateTime.new(2026, 8, 13, 13, 5, 6, "+09:00") }

      it "UTCへ変換された値になる" do
        expect(instance.to_hexdigest_source).to eq "2026-08-13T04:05:06.000000000Z"
      end
    end

    context "Dateと同じ日付を持つ場合" do
      let(:instance) { ::DateTime.new(2026, 8, 13) }

      it "Dateの実装は継承されず、時刻を含む値になる" do
        expect(instance.to_hexdigest_source).not_to eq ::Date.new(2026, 8, 13).to_hexdigest_source
      end
    end
  end

  describe "#to_hexdigest" do
    it "同じ瞬間を指すTimeと同じダイジェストにはならない（型で区別される）" do
      instance = ::DateTime.new(2026, 8, 13, 4, 5, 6, "+00:00")

      expect(instance.to_hexdigest).not_to eq ::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest
    end

    it "同じ瞬間を指す日時はオフセットが違っても同じダイジェストになる" do
      expect(::DateTime.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest)
        .to eq ::DateTime.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest
    end
  end
end
