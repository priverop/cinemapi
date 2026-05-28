# frozen_string_literal: true

require_relative '../../../../lib/scraper/golem/detail_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Golem::DetailParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures/golem') }
  let(:html)          { File.read(File.join(fixtures_path, 'detail.html')) }

  describe "#parse" do
    subject(:detail) { described_class.new(html).parse }

    it "extracts the duration label" do
      expect(detail[:duration]).to eq("159 min.")
    end

    context "when the field is absent" do
      it "returns nil without raising" do
        result = described_class.new("<html><body></body></html>").parse
        expect(result[:duration]).to be_nil
      end
    end

    context "with blank input" do
      it "returns nil without raising" do
        expect(described_class.new("").parse[:duration]).to be_nil
      end
    end
  end
end
