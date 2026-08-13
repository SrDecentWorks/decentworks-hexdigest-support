# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Date do
  describe "#to_hexdigest_type" do
    it "Timeへは正規化されない（1日を指す型のため）" do
      expect(described_class.new(2026, 8, 13).to_hexdigest_type).to eq "Date"
    end
  end

  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "日付の場合" do
      let(:instance) { described_class.new(2026, 8, 13) }

      it { is_expected.to eq "2026-08-13" }
    end

    context "1桁の月日の場合" do
      let(:instance) { described_class.new(2026, 1, 2) }

      it "ゼロ埋めされる" do
        is_expected.to eq "2026-01-02"
      end
    end

    context "うるう日の場合" do
      let(:instance) { described_class.new(2024, 2, 29) }

      it { is_expected.to eq "2024-02-29" }
    end

    # MEMO: %Yは固定長ではないため、4桁を超える年や紀元前では長さや符号が変わる。
    #       ダイジェストの入力に可変長が混ざる点をここで固定しておく
    context "年が4桁未満の場合" do
      let(:instance) { described_class.new(999, 1, 2) }

      it "4桁までゼロ埋めされる" do
        is_expected.to eq "0999-01-02"
      end
    end

    context "年が4桁を超える場合" do
      let(:instance) { described_class.new(12_345, 1, 2) }

      it "年の桁数がそのまま出る" do
        is_expected.to eq "12345-01-02"
      end
    end

    context "紀元前の場合" do
      let(:instance) { described_class.new(-1, 1, 2) }

      it "符号が付く" do
        is_expected.to eq "-0001-01-02"
      end
    end
  end

  describe "#to_hexdigest" do
    it "同じ日付なら別インスタンスでも同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect(described_class.new(2026, 8, 13).to_hexdigest).to eq described_class.new(2026, 8, 13).to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end

    it "日付が違えば異なるダイジェストになる" do
      expect(described_class.new(2026, 8, 13).to_hexdigest).not_to eq described_class.new(2026, 8, 14).to_hexdigest
    end

    it "同じ表記の文字列とは異なるダイジェストになる（型で区別される）" do
      expect(described_class.new(2026, 8, 13).to_hexdigest).not_to eq "2026-08-13".to_hexdigest
    end

    it "範囲の端点に置いた場合、同じ表記の文字列の範囲とは異なるダイジェストになる" do
      dates = described_class.new(2026, 8, 1)..described_class.new(2026, 8, 31)

      expect(dates.to_hexdigest).not_to eq ("2026-08-01".."2026-08-31").to_hexdigest
    end
  end
end
