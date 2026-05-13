# frozen_string_literal: true

require_relative '../../../../lib/scraper/mk2/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Mk2::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'mk2') }

  describe "#days" do
    context "valid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'cartelera.html')) }

      it "returns multiple day entries" do
        expect(described_class.new(html).days.count).to be > 1
      end

      it "each entry has a num and a Date" do
        first = described_class.new(html).days.first
        expect(first[:num]).to eq(0)
        expect(first[:date]).to be_a(Date)
      end

      it "parses Hoy as today" do
        expect(described_class.new(html).days.first[:date]).to eq(Date.today)
      end

      it "parses Mañana as tomorrow" do
        expect(described_class.new(html).days[1][:date]).to eq(Date.today + 1)
      end
    end

    context "HTML with known DD/MM label" do
      let(:html) do
        <<~HTML
          <div class="rotulo_dia cambiar-dia" data-num="0">Hoy</div>
          <div class="rotulo_dia cambiar-dia" data-num="1">Mañana</div>
          <div class="rotulo_dia cambiar-dia" data-num="2">Viernes 15/05</div>
        HTML
      end

      it "parses DD/MM label into correct Date" do
        day = described_class.new(html).days.find { |d| d[:num] == 2 }
        expect(day[:date]).to eq(Date.new(Date.today.year, 5, 15))
      end
    end

    context "empty HTML" do
      it "raises CalendarNotFoundError" do
        expect { described_class.new("").days }.to raise_error(Scraper::CalendarNotFoundError, "Calendar not found.")
      end
    end
  end
end
