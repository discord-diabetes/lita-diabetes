require "lita-diabetes"
require "spec_helper"

describe Lita::Handlers::Diabetes, lita_handler: true do
    it { is_expected.to route "45" }
    it { is_expected.to route "7.9" }
    it { is_expected.to route_command "estimate a1c 102" }
    it { is_expected.to route_command "estimate a1c 4.9" }
    it { is_expected.to route_command "estimate average 5.7" }
    it { is_expected.to route_command "estimate average 45" }
    it "converts mg/dL to mmol/L" do
      send_message("90")
      expect(replies.last).to eq("90 mg/dL is 5.0 mmol/L")
    end
    it "converts mmol/L to mg/dL" do
      send_message("5.5")
      expect(replies.last).to eq("5.5 mmol/L is 99 mg/dL")
    end
    it "ignores URI in message" do
      send_message("https://www.reddit.com/r/diabetes/comments/354r77/20yo_diagnosed_with_type_1_today/cr17as0?context=3")
      expect(replies.last).to be(nil)
    end
end
