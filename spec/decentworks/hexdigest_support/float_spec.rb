# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Float do
  describe "#to_hexdigest_rational" do
    subject { instance.to_hexdigest_rational }

    # MEMO: #to_rなら3602879701896397/36028797018963968になる。見た目どおりの十進として
    #       読んでいることを、この1件で担保している
    context "2進で表現できない小数の場合" do
      let(:instance) { 0.1 }

      it "2進の厳密値ではなく十進として読まれる" do
        expect(subject).to eq Rational(1, 10)
      end
    end

    context "2進で表現できる小数の場合" do
      let(:instance) { 0.25 }

      it { is_expected.to eq Rational(1, 4) }
    end

    context "計算誤差を含む小数の場合" do
      let(:instance) { 0.1 + 0.2 }

      # MEMO: Float#to_sは元の値へ復元できる最短表記を返すため、誤差そのものも
      #       十進として保たれる。0.3へ丸められてしまわないことを固定しておく
      it "誤差を含んだままの十進として読まれる" do
        expect(subject).to eq Rational(30_000_000_000_000_004, 100_000_000_000_000_000)
      end
    end
  end

  describe "#to_hexdigest" do
    it "#==が真になる小数同士は同じダイジェストになる" do
      expect((0.1 + 0.2).to_hexdigest).to eq 0.30000000000000004.to_hexdigest
    end

    it "計算誤差を含む値と、丸めた値は異なるダイジェストになる" do
      expect((0.1 + 0.2).to_hexdigest).not_to eq 0.3.to_hexdigest
    end
  end
end
