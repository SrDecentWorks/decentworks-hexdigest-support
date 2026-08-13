# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Time do
  describe "#to_hexdigest_type" do
    it { expect(described_class.utc(2026, 8, 13).to_hexdigest_type).to eq "Time" }
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "UTCの時刻の場合" do
      let(:instance) { described_class.utc(2026, 8, 13, 4, 5, 6) }

      it { is_expected.to eq "2026-08-13T04:05:06.000000000Z" }
    end

    context "オフセットを持つ時刻の場合" do
      let(:instance) { described_class.new(2026, 8, 13, 13, 5, 6, "+09:00") }

      it "UTCへ変換された値になる" do
        is_expected.to eq "2026-08-13T04:05:06.000000000Z"
      end

      it "同じ瞬間を指すUTCの時刻と同じ値になる" do
        is_expected.to eq described_class.utc(2026, 8, 13, 4, 5, 6).to_hexdigest_source
      end
    end

    # MEMO: Time.utcの第7引数はマイクロ秒。Rational(1, 1000)μsで1ナノ秒を表す
    context "ナノ秒の精度を持つ場合" do
      let(:instance) { described_class.utc(2026, 8, 13, 4, 5, 6, Rational(1, 1000)) }

      it "ナノ秒まで保持される" do
        is_expected.to eq "2026-08-13T04:05:06.000000001Z"
      end

      it "秒未満が異なれば異なる値になる" do
        is_expected.not_to eq described_class.utc(2026, 8, 13, 4, 5, 6).to_hexdigest_source
      end
    end

    context "マイクロ秒の精度を持つ場合" do
      let(:instance) { described_class.utc(2026, 8, 13, 4, 5, 6, 123_456) }

      it { is_expected.to eq "2026-08-13T04:05:06.123456000Z" }
    end

    # MEMO: Rational(1, 1_000_000)μs = 1ピコ秒。ナノ秒の桁には現れない
    context "ナノ秒より細かい精度を持つ場合" do
      let(:instance) { described_class.utc(2026, 8, 13, 4, 5, 6, Rational(1, 1_000_000)) }

      it "切り捨てられて秒ちょうどと同じ値になる" do
        is_expected.to eq "2026-08-13T04:05:06.000000000Z"
      end
    end

    # MEMO: 999.5ナノ秒相当。四捨五入なら...000001000になる
    context "ナノ秒未満が繰り上がる大きさの場合" do
      let(:instance) { described_class.utc(2026, 8, 13, 4, 5, 6, Rational(1999, 2000)) }

      it "四捨五入ではなく切り捨てられる" do
        is_expected.to eq "2026-08-13T04:05:06.000000999Z"
      end
    end

    context "年が4桁を超える場合" do
      let(:instance) { described_class.utc(12_345, 1, 2, 3, 4, 5) }

      # MEMO: %Yは固定長ではないため、年の桁数がそのまま出る
      it "年の桁数がそのまま出る" do
        is_expected.to eq "12345-01-02T03:04:05.000000000Z"
      end
    end
  end

  describe "#to_hexdigest" do
    it "同じ瞬間を指す時刻はタイムゾーンが違っても同じダイジェストになる" do
      expect(described_class.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest)
        .to eq described_class.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest
    end

    it "時刻が違えば異なるダイジェストになる" do
      expect(described_class.utc(2026, 8, 13, 4, 5, 6).to_hexdigest)
        .not_to eq described_class.utc(2026, 8, 13, 4, 5, 7).to_hexdigest
    end

    it "同じ表記の文字列とは異なるダイジェストになる（型で区別される）" do
      expect(described_class.utc(2026, 8, 13, 4, 5, 6).to_hexdigest)
        .not_to eq "2026-08-13T04:05:06.000000000Z".to_hexdigest
    end

    it "範囲の端点に置いても同じ瞬間なら同じダイジェストになる" do
      jst = described_class.new(2026, 8, 13, 9, 0, 0, "+09:00")..described_class.new(2026, 8, 14, 9, 0, 0, "+09:00")
      utc = described_class.utc(2026, 8, 13, 0, 0, 0)..described_class.utc(2026, 8, 14, 0, 0, 0)

      expect(jst.to_hexdigest).to eq utc.to_hexdigest
    end
  end
end
