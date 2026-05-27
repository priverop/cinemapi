# frozen_string_literal: true

require_relative '../../../../lib/scraper/malda/calendar_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Malda::CalendarParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'malda') }
  let(:html) { File.read(File.join(fixtures_path, 'cartelera.html')) }

  describe "#movies" do
    context "valid HTML" do
      subject(:movies) { described_class.new(html).movies }

      it "returns one entry per unique movie title" do
        titles = movies.map { |m| m[:title] }
        expect(titles).to eq(titles.uniq)
      end

      it "extracts every film of the week (including ones absent from the widget)" do
        titles = movies.map { |m| m[:title] }
        expect(titles).to include("RESURRECTION", "KILL BILL: THE WHOLE BLOODY AFFAIR", "SORDA")
        expect(titles.size).to eq(11)
      end

      it "builds the correct datetime from the header month/year and the day number" do
        resurrection = movies.find { |m| m[:title] == "RESURRECTION" }
        expect(resurrection[:showtimes]).to eq([ Time.utc(2026, 5, 26, 17, 5) ])
      end

      it "keeps the raw language tag per movie" do
        flores = movies.find { |m| m[:title] == "FLORES PARA ANTONIO" }
        expect(flores[:language]).to eq("VOE")
        expect(movies.find { |m| m[:title] == "SORDA" }[:language]).to eq("VOE")
        expect(movies.find { |m| m[:title] == "RESURRECTION" }[:language]).to eq("VOSE")
      end

      it "strips trailing notes from the title" do
        prime = movies.find { |m| m[:title].start_with?("PRIME CRIME") }
        expect(prime[:title]).to eq("PRIME CRIME A TRUE STORY")
      end

      it "assigns sessions to the correct day of the week" do
        agente = movies.find { |m| m[:title] == "EL AGENTE SECRETO" }
        expect(agente[:showtimes]).to eq([ Time.utc(2026, 5, 27, 12, 15) ])
      end
    end

    context "schedule with two week sections" do
      let(:html) { File.read(File.join(fixtures_path, 'cartelera_two_weeks.html')) }
      subject(:movies) { described_class.new(html).movies }

      it "parses films from both weeks" do
        titles = movies.map { |m| m[:title] }
        expect(titles).to include("SORDA", "HANGAR ROJO")
      end

      it "dates the second week against its own header month" do
        hangar = movies.find { |m| m[:title] == "HANGAR ROJO" }
        expect(hangar[:showtimes]).to eq([ Time.utc(2026, 6, 4, 16, 45) ])
      end

      it "keeps a wrap day (start > end) in the starting month, not the header month" do
        dos_dias = movies.find { |m| m[:title] == "DOS DÍAS" }
        expect(dos_dias[:showtimes]).to eq([ Time.utc(2026, 5, 29, 15, 30) ])
      end

      it "spans a film across both months within one week" do
        drama = movies.find { |m| m[:title] == "EL DRAMA" }
        expect(drama[:showtimes]).to include(Time.utc(2026, 5, 29, 18, 35), Time.utc(2026, 6, 4, 18, 15))
      end

      it "skips non-film lines that lack a language tag (hall rentals, events)" do
        titles = movies.map { |m| m[:title] }
        expect(titles).not_to include(a_string_matching(/LLOGUER DE SALA/))
      end
    end

    context "cross-month week" do
      let(:cross_html) do
        <<~HTML
          <div class="sinopsi">
            <h2><strong><u>CARTELERA DEL 29 DE MAYO AL 4 DE JUNIO DE 2026</u></strong></h2>
            <p><span><strong>VIERNES 29</strong></span><br /> 18:00h &#8211; PELICULA A (VOSE)</p>
            <p><span><strong>LUNES 1</strong></span><br /> 20:00h &#8211; PELICULA B (VOE)</p>
          </div>
        HTML
      end

      it "resolves day numbers below the start day to the second month" do
        movies = described_class.new(cross_html).movies
        a = movies.find { |m| m[:title] == "PELICULA A" }
        b = movies.find { |m| m[:title] == "PELICULA B" }
        expect(a[:showtimes]).to eq([ Time.utc(2026, 5, 29, 18, 0) ])
        expect(b[:showtimes]).to eq([ Time.utc(2026, 6, 1, 20, 0) ])
      end
    end

    context "empty html" do
      it "raises CalendarNotFoundError" do
        expect { described_class.new("").movies }.to raise_error(Scraper::CalendarNotFoundError, "Calendar not found.")
      end
    end

    context "header missing" do
      it "raises CalendarNotFoundError" do
        html = '<div class="sinopsi"><p>nothing here</p></div>'
        expect { described_class.new(html).movies }.to raise_error(Scraper::CalendarNotFoundError)
      end
    end
  end
end
