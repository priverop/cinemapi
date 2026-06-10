# frozen_string_literal: true

require_relative '../../../../lib/scraper/embajadores/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Embajadores::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'embajadores') }

  describe "#days" do
    context "valid HTML" do
      let(:html)  { File.read(File.join(fixtures_path, 'cartelera.html')) }
      let(:today) { Date.new(2026, 5, 13) }

      it "returns 7 day entries" do
        expect(described_class.new(html, today: today).days.count).to eq(7)
      end

      it "each entry has a :url and :date" do
        first = described_class.new(html, today: today).days.first
        expect(first[:url]).to be_a(String).and include("cartelera-del-dia")
        expect(first[:date]).to be_a(Date)
      end

      it "parses Hoy as the injected today" do
        expect(described_class.new(html, today: today).days.first[:date]).to eq(today)
      end

      it "parses consecutive days in order" do
        days = described_class.new(html, today: today).days
        expect(days[1][:date]).to eq(days[0][:date] + 1)
      end
    end

    context "minimal HTML with known day links" do
      let(:html) do
        <<~HTML
          <h2 class="separador">
            <a class="cartelera-dia" href="https://cinesembajadores.es/madrid/cartelera-del-dia/?ciudad=madrid">Hoy.13/05</a>
            <a class="cartelera-dia" href="https://cinesembajadores.es/madrid/cartelera-del-dia/?dia=1&ciudad=madrid">Jue.14/05</a>
          </h2>
        HTML
      end

      it "parses DD/MM label into correct Date" do
        day = described_class.new(html, today: Date.new(2026, 5, 13)).days[1]
        expect(day[:date]).to eq(Date.new(2026, 5, 14))
      end

      it "includes the full URL" do
        day = described_class.new(html).days[1]
        expect(day[:url]).to eq("https://cinesembajadores.es/madrid/cartelera-del-dia/?dia=1&ciudad=madrid")
      end
    end

    context "empty HTML" do
      it "raises CalendarNotFoundError" do
        expect { described_class.new("").days }.to raise_error(Scraper::CalendarNotFoundError, "Calendar not found.")
      end
    end
  end
end
