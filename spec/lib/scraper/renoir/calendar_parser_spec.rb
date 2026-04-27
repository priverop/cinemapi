# frozen_string_literal: true

require_relative '../../../../lib/scraper/renoir/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Renoir::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'renoir') }

  describe "#urls" do
    context "valid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'princesa.html')) }

      it "returns the right amount of day URLs" do
        parser = described_class.new(html)
        expect(parser.urls.count).to eq(7)
      end

      it "returns paths starting with /cine/" do
        parser = described_class.new(html)
        expect(parser.urls.first).to eq("/cine/cines-princesa/cartelera/?fecha=2026-04-23")
      end
    end

    context "empty html" do
      it "raises CalendarNotFoundError" do
        parser = described_class.new("")
        expect { parser.urls }.to raise_error(Scraper::CalendarNotFoundError, "Calendar not found.")
      end
    end
  end
end
