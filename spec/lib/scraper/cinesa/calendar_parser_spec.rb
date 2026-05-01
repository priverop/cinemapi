# frozen_string_literal: true

require_relative '../../../../lib/scraper/cinesa/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Cinesa::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'cinesa') }

  describe "#parse" do
    context "valid JSON" do
      let(:input) { File.read(File.join(fixtures_path, 'film_screening_dates.json')) }

      it "returns the right amount of dates" do
        parser = described_class.new(input)
        expect(parser.parse.count).to eq(8)
      end

      it "returns businessDate strings" do
        parser = described_class.new(input)
        expect(parser.parse.first).to eq("2026-04-27")
      end
    end

    context "missing filmScreeningDates key" do
      it "raises CalendarNotFoundError" do
        parser = described_class.new('{}')
        expect { parser.parse }.to raise_error Scraper::CalendarNotFoundError, "Calendar not found."
      end
    end

    context "empty input" do
      it "raises JSON::ParserError" do
        expect do
          described_class.new("")
        end.to raise_error JSON::ParserError, /unexpected/
      end
    end
  end
end
