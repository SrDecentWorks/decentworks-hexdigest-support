# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Decentworks::HexdigestSupport::NumericLike do
  describe "#to_hexdigest_type" do
    it "数を表す型はすべてNumericへ正規化される" do
      types = [1, 1.0, Rational(1, 2), BigDecimal("1")].map(&:to_hexdigest_type)

      expect(types).to eq %w[Numeric Numeric Numeric Numeric]
    end

    # MEMO: Complexは実部と虚部の組であり有理数へ変換できないため、NumericLikeの
    #       対象外としている。対象を広げたときに気付けるよう固定しておく
    it "Complexは正規化の対象外" do
      expect(Complex(1, 2).to_hexdigest_type).to eq "Complex"
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "整数の場合" do
      let(:instance) { 42 }

      it { is_expected.to eq "42" }
    end

    context "負の整数の場合" do
      let(:instance) { -42 }

      it { is_expected.to eq "-42" }
    end

    context "小数部を持たない小数の場合" do
      let(:instance) { 1.0 }

      it "整数と同じ表記になる" do
        expect(subject).to eq "1"
      end
    end

    context "有限小数の場合" do
      let(:instance) { 0.25 }

      it { is_expected.to eq "0.25" }
    end

    context "負の有限小数の場合" do
      let(:instance) { -0.25 }

      it "整数部が0でも符号が付く" do
        expect(subject).to eq "-0.25"
      end
    end

    context "有限小数で表せない有理数の場合" do
      let(:instance) { Rational(1, 3) }

      it "分数表記になる" do
        expect(subject).to eq "1/3"
      end
    end

    context "約分できる有理数の場合" do
      let(:instance) { Rational(2, 4) }

      it "既約分数として表記される" do
        expect(subject).to eq "0.5"
      end
    end

    context "負のゼロの場合" do
      let(:instance) { -0.0 }

      it "ゼロと同じ表記になる" do
        expect(subject).to eq "0"
      end
    end

    context "指数表記になる大きな小数の場合" do
      let(:instance) { 1e20 }

      # MEMO: Float#to_sは"1.0e+20"を返すが、入力に指数表記が混ざると同じ数でも
      #       表記が割れる。十進へ展開されることを固定しておく
      it "十進へ展開される" do
        expect(subject).to eq "100000000000000000000"
      end
    end

    context "指数表記になる小さな小数の場合" do
      let(:instance) { 1e-9 }

      it "十進へ展開される" do
        expect(subject).to eq "0.000000001"
      end
    end

    context "NaNの場合" do
      let(:instance) { ::Float::NAN }

      it { is_expected.to eq "NaN" }
    end

    context "正の無限大の場合" do
      let(:instance) { ::Float::INFINITY }

      it { is_expected.to eq "Infinity" }
    end

    context "負の無限大の場合" do
      let(:instance) { -::Float::INFINITY }

      it { is_expected.to eq "-Infinity" }
    end
  end

  describe "#to_hexdigest" do
    context "同じ数を異なるクラスで表した場合" do
      it "整数と小数は同じダイジェストになる" do
        expect(1.to_hexdigest).to eq 1.0.to_hexdigest
      end

      it "整数とBigDecimalは同じダイジェストになる" do
        expect(1.to_hexdigest).to eq BigDecimal("1.00").to_hexdigest
      end

      it "整数と有理数は同じダイジェストになる" do
        expect(1.to_hexdigest).to eq Rational(2, 2).to_hexdigest
      end

      it "小数とBigDecimalは同じダイジェストになる" do
        expect(1.5.to_hexdigest).to eq BigDecimal("1.5").to_hexdigest
      end

      # MEMO: 2進では表現できない値。Float#to_rの厳密値（3602879701896397/36028797018963968）
      #       を使うと一致しなくなるため、十進として読んでいることの担保になる
      it "2進で表現できない小数でもBigDecimalと同じダイジェストになる" do
        expect(0.1.to_hexdigest).to eq BigDecimal("0.1").to_hexdigest
      end

      it "2進で表現できない小数でも有理数と同じダイジェストになる" do
        expect(0.1.to_hexdigest).to eq Rational(1, 10).to_hexdigest
      end

      it "負のゼロとゼロは同じダイジェストになる" do
        expect((-0.0).to_hexdigest).to eq 0.to_hexdigest
      end

      it "NaN同士は同じダイジェストになる" do
        expect(::Float::NAN.to_hexdigest).to eq BigDecimal("NaN").to_hexdigest
      end
    end

    context "異なる数の場合" do
      it "整数が違えば異なるダイジェストになる" do
        expect(1.to_hexdigest).not_to eq 2.to_hexdigest
      end

      it "有限小数で表せない有理数と、その近似値の小数は異なるダイジェストになる" do
        expect(Rational(1, 3).to_hexdigest).not_to eq (1.0 / 3).to_hexdigest
      end

      it "NaNと無限大は異なるダイジェストになる" do
        expect(::Float::NAN.to_hexdigest).not_to eq ::Float::INFINITY.to_hexdigest
      end
    end

    context "同じ表記の他の型と比べた場合" do
      it "整数と文字列は異なるダイジェストになる（型で区別される）" do
        expect(1.to_hexdigest).not_to eq "1".to_hexdigest
      end

      it "分数表記の有理数と同じ表記の文字列は異なるダイジェストになる" do
        expect(Rational(1, 3).to_hexdigest).not_to eq "1/3".to_hexdigest
      end

      it "無限大と同じ表記の文字列は異なるダイジェストになる" do
        expect(::Float::INFINITY.to_hexdigest).not_to eq "Infinity".to_hexdigest
      end

      # MEMO: Complexは正規化の対象外なので、実部だけのComplexも数とは一致しない
      it "整数と実部だけのComplexは異なるダイジェストになる" do
        expect(1.to_hexdigest).not_to eq Complex(1, 0).to_hexdigest
      end
    end

    context "構造の中に置いた場合" do
      it "配列の要素でも同じ数なら同じダイジェストになる" do
        expect([1, 2].to_hexdigest).to eq [1.0, BigDecimal("2")].to_hexdigest
      end

      it "ハッシュの値でも同じ数なら同じダイジェストになる" do
        expect({ price: 1 }.to_hexdigest).to eq({ price: BigDecimal("1") }.to_hexdigest)
      end

      it "ハッシュのキーでも同じ数なら同じダイジェストになる" do
        expect({ 1 => :x }.to_hexdigest).to eq({ 1.0 => :x }.to_hexdigest)
      end

      it "範囲の端点でも同じ数なら同じダイジェストになる" do
        expect((1..3).to_hexdigest).to eq (1.0..3.0).to_hexdigest
      end
    end
  end
end
