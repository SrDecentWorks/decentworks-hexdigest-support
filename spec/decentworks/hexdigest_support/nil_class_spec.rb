# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::NilClass do
  describe "#to_hexdigest_source" do
    it { expect(nil.to_hexdigest_source).to eq "nil" }
  end

  describe "#to_hexdigest_input" do
    it { expect(nil.to_hexdigest_input).to eq 'NilClass:"nil"' }

    it "空文字の文字列とは異なる入力になる" do
      expect(nil.to_hexdigest_input).not_to eq "".to_hexdigest_input
    end

    it '文字列の"nil"とは異なる入力になる' do
      expect(nil.to_hexdigest_input).not_to eq "nil".to_hexdigest_input
    end
  end

  describe "#to_hexdigest" do
    it "空文字の文字列とは異なるダイジェストになる" do
      expect(nil.to_hexdigest).not_to eq "".to_hexdigest
    end

    it "falseとは異なるダイジェストになる" do
      expect(nil.to_hexdigest).not_to eq false.to_hexdigest
    end
  end

  describe "真偽値" do
    it { expect(true.to_hexdigest_input).to eq 'TrueClass:"true"' }
    it { expect(false.to_hexdigest_input).to eq 'FalseClass:"false"' }

    it "trueとfalseは異なるダイジェストになる" do
      expect(true.to_hexdigest).not_to eq false.to_hexdigest
    end

    it "真偽値と同じ表記の文字列は異なるダイジェストになる" do
      expect(true.to_hexdigest).not_to eq "true".to_hexdigest
    end
  end

  describe "構造の要素としてのnil" do
    it "値がnilの要素と要素そのものがない場合は異なる値になる" do
      expect({ a: nil }.to_hexdigest_source).not_to eq({}.to_hexdigest_source)
    end

    it "値がnilの要素と空文字の要素は異なる値になる" do
      expect({ a: nil }.to_hexdigest_source).not_to eq({ a: "" }.to_hexdigest_source)
    end

    it { expect([nil].to_hexdigest_source).to eq '[NilClass:"nil"]' }
  end
end
