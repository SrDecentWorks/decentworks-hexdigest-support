# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Time do
  describe "#to_hexdigest_type" do
    it { expect(::Time.utc(2026, 8, 13).to_hexdigest_type).to eq "Time" }
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "UTCの時刻の場合" do
      let(:instance) { ::Time.utc(2026, 8, 13, 4, 5, 6) }

      it { is_expected.to eq "2026-08-13T04:05:06.000000000Z" }
    end

    context "オフセットを持つ時刻の場合" do
      let(:instance) { ::Time.new(2026, 8, 13, 13, 5, 6, "+09:00") }

      it "UTCへ変換された値になる" do
        expect(instance.to_hexdigest_source).to eq "2026-08-13T04:05:06.000000000Z"
      end

      it "同じ瞬間を指すUTCの時刻と同じ値になる" do
        expect(instance.to_hexdigest_source).to eq ::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest_source
      end
    end

    context "小数秒を持つ場合" do
      let(:instance) { ::Time.utc(2026, 8, 13, 4, 5, 6, 123_456.789r) }

      it "ナノ秒まで保持される" do
        expect(instance.to_hexdigest_source).to eq "2026-08-13T04:05:06.123456789Z"
      end

      it "秒未満が異なれば異なる値になる" do
        expect(instance.to_hexdigest_source).not_to eq ::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest_source
      end
    end

    context "ナノ秒より細かい精度を持つ場合" do
      let(:instance) { ::Time.utc(2026, 8, 13, 4, 5, 6, Rational(1, 1000)) }

      it "ナノ秒までで切り捨てられる" do
        expect(instance.to_hexdigest_source).to eq "2026-08-13T04:05:06.000000001Z"
      end
    end
  end

  describe "#to_hexdigest" do
    it "同じ瞬間を指す時刻はタイムゾーンが違っても同じダイジェストになる" do
      expect(::Time.new(2026, 8, 13, 13, 5, 6, "+09:00").to_hexdigest)
        .to eq ::Time.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest
    end

    it "時刻が違えば異なるダイジェストになる" do
      expect(::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest).not_to eq ::Time.utc(2026, 8, 13, 4, 5, 7).to_hexdigest
    end

    it "同じ表記の文字列とは異なるダイジェストになる（型で区別される）" do
      instance = ::Time.utc(2026, 8, 13, 4, 5, 6)

      expect(instance.to_hexdigest).not_to eq instance.to_hexdigest_source.to_hexdigest
    end
  end
end
