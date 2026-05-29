# frozen_string_literal: true

require_relative '../../../../lib/scraper/zumzeig/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Zumzeig::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'zumzeig') }
  let(:html) { File.read(File.join(fixtures_path, 'calendario_home.html')) }
  let(:today) { Date.new(2026, 5, 20) }

  describe "#movies" do
    context "valid HTML" do
      it "returns one entry per unique movie URL" do
        parser = described_class.new(html, today: today)
        urls = parser.movies.map { |m| m[:url] }
        expect(urls).to eq(urls.uniq)
        expect(urls).to include("/cinema/films/la-chica-del-coro/")
      end

      it "groups all showtimes for a movie under one entry" do
        parser = described_class.new(html, today: today)
        chica = parser.movies.find { |m| m[:url] == "/cinema/films/la-chica-del-coro/" }
        expect(chica[:showtimes]).to include(Time.utc(2026, 5, 20, 18, 30))
        expect(chica[:showtimes].size).to be >= 2
      end

      it "builds Time objects with the correct date from month name + day" do
        parser = described_class.new(html, today: today)
        first_movie = parser.movies.first
        expect(first_movie[:showtimes].first).to be_a(Time)
      end
    end

    context "empty html" do
      it "raises CalendarNotFoundError" do
        parser = described_class.new("", today: today)
        expect { parser.movies }.to raise_error(Scraper::CalendarNotFoundError, "Calendar not found.")
      end
    end

    context "year rollover" do
      let(:html_dec) do
        <<~HTML
          <div class="calendarlist">
            <h5 class="monthname">Gener</h5>
            <div class="day">
              <table class="daytable">
                <tr><th class="dianum first">5</th><th class="dianame">Dilluns</th></tr>
                <tr class="sessio"><td class="hora">20:00</td><td class="filmtitlecal"><a href="/cinema/films/x/">X</a></td><td class="autor">Y</td></tr>
              </table>
            </div>
          </div>
        HTML
      end

      it "uses next year when month is before today's month" do
        parser = described_class.new(html_dec, today: Date.new(2026, 12, 20))
        movie = parser.movies.first
        expect(movie[:showtimes].first).to eq(Time.utc(2027, 1, 5, 20, 0))
      end
    end
  end
end
