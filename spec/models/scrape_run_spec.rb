require "rails_helper"

RSpec.describe ScrapeRun do
  describe "associations" do
    it { is_expected.to belong_to(:theater) } if respond_to?(:belong_to)
  end

  describe "#record_failure" do
    let(:scrape_run) { create(:scrape_run) }

    it "creates a scrape_failure with given context and error message" do
      expect {
        scrape_run.record_failure(context: "2026-05-28", error_message: "boom")
      }.to change { scrape_run.scrape_failures.count }.by(1)

      failure = scrape_run.scrape_failures.last
      expect(failure.context).to eq("2026-05-28")
      expect(failure.error_message).to eq("boom")
    end
  end

  describe "#finalize!" do
    let(:scrape_run) { create(:scrape_run, status: :running) }

    context "when there are no failures" do
      it "marks the run as success" do
        scrape_run.finalize!
        expect(scrape_run.reload).to be_success
      end
    end

    context "when there are failures" do
      before { create(:scrape_failure, scrape_run: scrape_run) }

      it "marks the run as failed" do
        scrape_run.finalize!
        expect(scrape_run.reload).to be_failed
      end
    end
  end

  describe "default values" do
    it "starts with items_ok and items_failed at zero" do
      run = ScrapeRun.new(theater: create(:theater))
      expect(run.items_ok).to eq(0)
      expect(run.items_failed).to eq(0)
    end
  end
end
