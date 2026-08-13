# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::Date do
  describe "#to_hexdigest_source" do
    subject { instance.to_hexdigest_source }

    context "日付の場合" do
      let(:instance) { ::Date.new(2026, 8, 13) }

      it { is_expected.to eq "2026-08-13" }
    end

    context "1桁の月日の場合" do
      let(:instance) { ::Date.new(2026, 1, 2) }

      it "ゼロ埋めされる" do
        expect(instance.to_hexdigest_source).to eq "2026-01-02"
      end
    end
  end

  describe "#to_hexdigest" do
    it "同じ日付なら別インスタンスでも同じダイジェストになる" do
      # rubocop:disable RSpec/IdenticalEqualityAssertion
      expect(::Date.new(2026, 8, 13).to_hexdigest).to eq ::Date.new(2026, 8, 13).to_hexdigest
      # rubocop:enable RSpec/IdenticalEqualityAssertion
    end

    it "日付が違えば異なるダイジェストになる" do
      expect(::Date.new(2026, 8, 13).to_hexdigest).not_to eq ::Date.new(2026, 8, 14).to_hexdigest
    end

    it "同じ表記の文字列とは異なるダイジェストになる（型で区別される）" do
      expect(::Date.new(2026, 8, 13).to_hexdigest).not_to eq "2026-08-13".to_hexdigest
    end
  end
end
