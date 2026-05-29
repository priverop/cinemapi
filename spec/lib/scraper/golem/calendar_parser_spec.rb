# frozen_string_literal: true

require_relative '../../../../lib/scraper/golem/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Golem::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'golem') }

  describe "#days" do
    context "valid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'calendar.html')) }

      it "returns the right amount of day entries" do
        parser = described_class.new(html)
        expect(parser.days.count).to eq(6)
      end

      it "each entry has a url and a date" do
        parser = described_class.new(html)
        first = parser.days.first
        expect(first[:url]).to eq("/golem/golem-madrid/20260520")
        expect(first[:date]).to eq("2026-05-20")
      end
    end

    context "anchor with invalid date format" do
      let(:html) do
        <<~HTML
          <td class="tabNoDia"><a href="/golem/golem-madrid/notadate">Foo</a></td>
        HTML
      end

      it "skips the entry and logs a warning" do
        parser = described_class.new(html)
        expect(Scraper.logger).to receive(:warn).with(/Skipping calendar URL/)
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
