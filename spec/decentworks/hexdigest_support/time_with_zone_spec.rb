# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::ActiveSupport::TimeWithZone do
  # spec_helperでTime.zoneに"Asia/Tokyo"を設定している
  let(:instance) { ::Time.zone.local(2026, 8, 13, 13, 5, 6) }

  describe "拡張の適用" do
    # MEMO: TimeWithZoneはTimeのサブクラスではないため、Timeへの拡張は届かない。
    #       includeが漏れるとObject#to_hexdigest_source（＝#to_s）へ静かに
    #       フォールバックし、オフセットを含む文字列が入力になってしまう
    it "TimeLikeがincludeされている" do
      expect(described_class.include?(::Decentworks::HexdigestSupport::TimeLike)).to be true
    end
  end

  describe "#to_hexdigest_type" do
    it "Timeへ正規化される" do
      expect(instance.to_hexdigest_type).to eq "Time"
    end
  end

  describe "#to_hexdigest_source" do
    it "UTCへ変換された値になる" do
      expect(instance.to_hexdigest_source).to eq "2026-08-13T04:05:06.000000000Z"
    end

    it "タイムゾーンが違っても同じ瞬間なら同じ値になる" do
      in_utc = ::Time.find_zone!("UTC").local(2026, 8, 13, 4, 5, 6)

      expect(instance.to_hexdigest_source).to eq in_utc.to_hexdigest_source
    end

    it "マイクロ秒まで保持される" do
      with_usec = ::Time.zone.local(2026, 8, 13, 13, 5, 6, 123_456)

      expect(with_usec.to_hexdigest_source).to eq "2026-08-13T04:05:06.123456000Z"
    end
  end

  describe "#to_hexdigest" do
    it "同じ瞬間を指すTimeと同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq ::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest
    end

    it "秒未満を含んでいても同じ瞬間を指すTimeと同じダイジェストになる" do
      with_usec = ::Time.zone.local(2026, 8, 13, 13, 5, 6, 123_456)

      expect(with_usec.to_hexdigest).to eq ::Time.utc(2026, 8, 13, 4, 5, 6, 123_456).to_hexdigest
    end

    it "同じ瞬間を指すDateTimeと同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq ::DateTime.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest
    end

    # MEMO: 同じオブジェクトのダイジェストがTime.zoneの設定に引きずられないことを確認する。
    #       #to_sへフォールバックしていると、ここでオフセットが変わって落ちる
    it "同じオブジェクトのダイジェストはTime.zoneの設定を変えても不変" do
      before_digest = instance.to_hexdigest

      ::Time.use_zone("America/New_York") do
        expect(instance.to_hexdigest).to eq before_digest
      end
    end

    it "時刻が違えば異なるダイジェストになる" do
      expect(instance.to_hexdigest).not_to eq ::Time.zone.local(2026, 8, 13, 13, 5, 7).to_hexdigest
    end

    it "ハッシュの値に入れても同じ瞬間ならTimeと同じダイジェストになる" do
      expect({ at: instance }.to_hexdigest).to eq({ at: ::Time.utc(2026, 8, 13, 4, 5, 6) }.to_hexdigest)
    end
  end
end
