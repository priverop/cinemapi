require_relative '../../../../lib/scraper/mooby/detail_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Mooby::DetailParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures/mooby') }
  let(:html)          { File.read(File.join(fixtures_path, 'detail.html')) }

  describe "#parse" do
    subject(:detail) { described_class.new(html).parse }

    it "extracts the duration label" do
      expect(detail[:duration]).to eq("140 min.")
    end

    it "extracts the directors string" do
      expect(detail[:directors]).to eq("Antoine Fuqua, Jane Doe")
    end

    it "extracts the genres string" do
      expect(detail[:genres]).to eq("Drama, Musical")
    end

    it "extracts the synopsis as description" do
      expect(detail[:description]).to include("rei del pop")
    end

    it "extracts the poster" do
      expect(detail[:poster]).to eq("https://www.bizcochito.es/img/tt104102-ca-pos.webp")
    end

    context "when fields are absent" do
      it "returns nils without raising" do
        result = described_class.new("<html><body></body></html>").parse
        expect(result[:duration]).to be_nil
        expect(result[:directors]).to be_nil
      end
    end
  end
end
