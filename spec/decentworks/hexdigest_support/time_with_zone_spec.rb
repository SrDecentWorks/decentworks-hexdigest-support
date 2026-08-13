# frozen_string_literal: true

require "spec_helper"

RSpec.describe ::ActiveSupport::TimeWithZone do
  # spec_helperでTime.zoneに"Asia/Tokyo"を設定している
  let(:instance) { ::Time.zone.local(2026, 8, 13, 13, 5, 6) }

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
  end

  describe "#to_hexdigest" do
    it "同じ瞬間を指すTimeと同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq ::Time.utc(2026, 8, 13, 4, 5, 6).to_hexdigest
    end

    it "#to_timeで変換しても同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq instance.to_time.to_hexdigest
    end

    it "同じ瞬間を指すDateTimeと同じダイジェストになる" do
      expect(instance.to_hexdigest).to eq ::DateTime.new(2026, 8, 13, 4, 5, 6, "+00:00").to_hexdigest
    end

    it "Time.zoneの設定を変えてもダイジェストは変わらない" do
      before_digest = instance.to_hexdigest

      ::Time.use_zone("America/New_York") do
        expect(::Time.zone.local(2026, 8, 13, 0, 5, 6).to_hexdigest).to eq before_digest
      end
    end

    it "時刻が違えば異なるダイジェストになる" do
      expect(instance.to_hexdigest).not_to eq ::Time.zone.local(2026, 8, 13, 13, 5, 7).to_hexdigest
    end
  end
end
