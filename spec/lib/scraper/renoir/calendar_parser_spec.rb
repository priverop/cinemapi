# frozen_string_literal: true

require_relative '../../../../lib/scraper/renoir/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Renoir::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'renoir') }

  describe "#days" do
    context "valid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'princesa.html')) }

      it "returns the right amount of day entries" do
        parser = described_class.new(html)
        expect(parser.days.count).to eq(7)
      end

      it "each entry has a url and a date" do
        parser = described_class.new(html)
        first = parser.days.first
        expect(first[:url]).to eq("/cine/cines-princesa/cartelera/?fecha=2026-04-23")
        expect(first[:date]).to eq("2026-04-23")
      end
    end

    context "option with no fecha param" do
      let(:html) do
        <<~HTML
          <select id="elige-dia">
            <option value="/cine/cines-princesa/cartelera/">No fecha here</option>
          </select>
        HTML
      end

      it "skips the entry and logs a warning" do
        parser = described_class.new(html)
        expect(Scraper.logger).to receive(:warn).with(/Skipping calendar URL with no fecha param/)
        expect(parser.days).to be_empty
      end
    end

    context "empty html" do
      it "raises CalendarNotFoundError" do
        parser = described_class.new("")
        expect { parser.days }.to raise_error(Scraper::CalendarNotFoundError, "Calendar not found.")
      end
    end
  end
end
