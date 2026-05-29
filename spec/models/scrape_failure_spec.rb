require "rails_helper"

RSpec.describe ScrapeFailure do
  describe "validations" do
    it "requires an error_message" do
      failure = build(:scrape_failure, error_message: nil)
      expect(failure).not_to be_valid
    end

    it "allows a nil context (theater-level failure)" do
      failure = build(:scrape_failure, context: nil)
      expect(failure).to be_valid
    end
  end
end
