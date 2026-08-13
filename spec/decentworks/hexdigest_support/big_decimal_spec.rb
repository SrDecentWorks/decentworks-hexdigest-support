# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::BigDecimal do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    # MEMO: BigDecimal#to_sは"0.15e1"という内部表記を返す。これに依存していないことを
    #       固定しておく
    context "小数の場合" do
      let(:instance) { BigDecimal("1.5") }

      it "内部表記ではなく十進表記になる" do
        is_expected.to eq "1.5"
      end
    end

    context "末尾に0が付いた小数の場合" do
      let(:instance) { BigDecimal("1.50") }

      it "末尾の0は落ちる" do
        is_expected.to eq "1.5"
      end
    end

    context "指数表記で与えた場合" do
      let(:instance) { BigDecimal("1e2") }

      it "十進へ展開される" do
        is_expected.to eq "100"
      end
    end

    context "Floatでは表現できない桁数の場合" do
      let(:instance) { BigDecimal("0.12345678901234567890123456789") }

      it "桁が落ちない" do
        is_expected.to eq "0.12345678901234567890123456789"
      end
    end

    context "NaNの場合" do
      let(:instance) { BigDecimal("NaN") }

      it { is_expected.to eq "NaN" }
    end

    context "無限大の場合" do
      let(:instance) { BigDecimal("Infinity") }

      it { is_expected.to eq "Infinity" }
    end
  end

  describe "#to_hexdigest" do
    it "表記が違っても同じ数なら同じダイジェストになる" do
      expect(BigDecimal("1.50").to_hexdigest).to eq BigDecimal("1.5").to_hexdigest
    end

    it "Floatで丸められる桁は保たれる" do
      expect(BigDecimal("0.12345678901234567890123456789").to_hexdigest)
        .not_to eq BigDecimal("0.123456789012345678901234567890001").to_hexdigest
    end
  end
end
