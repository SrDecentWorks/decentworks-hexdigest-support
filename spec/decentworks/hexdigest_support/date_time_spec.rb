# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::DateTime do
  describe "メソッド解決順序" do
    # MEMO: TimeLikeがDateより手前に入っていないと、Date#to_hexdigest_sourceを
    #       継承して時刻が丸ごと落ちる
    it "TimeLikeがDateより手前に入る" do
      ancestors = described_class.ancestors

      expect(ancestors.index(::Decentworks::HexdigestSupport::TimeLike)).to be < ancestors.index(::Date)
    end
  end

  describe "#to_hexdigest_type" do
    it "Timeへ正規化される" do
      expect(described_class.new(2026, 8, 13).to_hexdigest_type).to eq "Time"
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "オフセットを持つ日時の場合" do
      let(:instance) { described_class.new(2026, 8, 13, 13, 5, 6, "+09:00") }

      it "UTCへ変換された値になる" do
        is_expected.to eq "2026-08-13T04:05:06.000000000Z"
      end
    end

    context "秒未満を持つ場合" do
      let(:instance) { described_class.new(2026, 8, 13, 13, 5, Rational(6_123_456, 1_000_000), "+09:00") }

      it "マイクロ秒まで保持される" do
        is_expected.to eq "2026-08-13T04:05:06.123456000Z"
      end
    end

    context "Dateと同じ日付を持つ場合" do
      let(:instance) { described_class.new(2026, 8, 13) }

      it "Dateの実装は継承されず、時刻を含む値になる" do
        is_expected.not_to eq ::Date.new(2026, 8, 13).to_hexdigest_source
      end
    end
  end

  describe "#to_hexdigest" do
    it "同じ瞬間を指すTimeと同じダイジェストになる" do
      expect(described_class.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest)
        .to eq ::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest
    end

    it "秒未満を含んでいても同じ瞬間を指すTimeと同じダイジェストになる" do
      instance = described_class.new(2026, 8, 13, 4, 5, Rational(6_123_456, 1_000_000), "+00:00")

      expect(instance.to_hexdigest).to eq ::Time.utc(2026, 8, 13, 4, 5, 6, 123_456).to_hexdigest
    end

    it "同じ瞬間を指す日時はオフセットが違っても同じダイジェストになる" do
      expect(described_class.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest)
        .to eq described_class.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest
    end

    it "同じ日付のDateとは異なるダイジェストになる" do
      expect(described_class.new(2026, 8, 13).to_hexdigest).not_to eq ::Date.new(2026, 8, 13).to_hexdigest
    end
  end
end
