# frozen_string_literal: true

require "spec_helper"

# MEMO: true / falseはObjectの既定（#to_s）のままなので、真偽値のテストはobject_specにある
RSpec.describe ::NilClass do
  describe "#to_hexdigest_source" do
    it { expect(nil.to_hexdigest_source).to eq "nil" }
  end

  describe "#to_hexdigest_input" do
    it { expect(nil.to_hexdigest_input).to eq 'NilClass:"nil"' }
  end

  describe "#to_hexdigest" do
    it "falseとは異なるダイジェストになる" do
      expect(nil.to_hexdigest).not_to eq false.to_hexdigest
    end

    it '文字列の"nil"とは異なるダイジェストになる（型で区別される）' do
      expect(nil.to_hexdigest).not_to eq "nil".to_hexdigest
    end
  end

  describe "構造の要素としてのnil" do
    it { expect([nil].to_hexdigest_source).to eq '[NilClass:"nil"]' }

    it "値がnilの要素と要素そのものがない場合は異なる値になる" do
      expect({ a: nil }.to_hexdigest_source).not_to eq({}.to_hexdigest_source)
    end

    it "値がnilの要素と空文字の要素は異なる値になる" do
      expect({ a: nil }.to_hexdigest_source).not_to eq({ a: "" }.to_hexdigest_source)
    end

    it "キーがnilの場合も他の型のキーと区別される" do
      expect({ nil => 1 }.to_hexdigest_source).not_to eq({ "" => 1 }.to_hexdigest_source)
    end
  end
end
