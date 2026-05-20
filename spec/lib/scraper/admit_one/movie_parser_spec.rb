# frozen_string_literal: true

require_relative '../../../../lib/scraper/admit_one/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::AdmitOne::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures/admit_one') }

  describe "#parse" do
    context "Verdi Madrid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'verdi_madrid.html')) }

      it "returns more than one movie" do
        movies = described_class.new(html).parse
        expect(movies).not_to be_empty
      end

      it "drops movies whose showtimes are CONCIERTO" do
        movies = described_class.new(html).parse
        expect(movies.none? { |m| m[:title].to_s.include?("Ópera y Ballet") }).to be(true)
      end

      it "extracts a movie with title, directors, duration, genres and per-showtime language" do
        movies = described_class.new(html).parse
        iron = movies.find { |m| m[:title].to_s.include?("Iron Maiden") }
        expect(iron).not_to be_nil
        expect(iron[:directors]).to eq("Malcolm Venville")
        expect(iron[:duration]).to include("105")
        expect(iron[:genres]).to include("Documental")
        expect(iron[:showtimes].first[:language]).to eq("V.O. SUB. CASTELLANO")
        expect(iron[:showtimes].first[:date]).to match(/\A\d{8} \d{2}:\d{2}\z/)
      end
    end

    context "Cinemes Girona HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'cinemes_girona.html')) }

      it "extracts movies with VOSE labels" do
        movies = described_class.new(html).parse
        couture = movies.find { |m| m[:title].to_s.include?("Couture") }
        expect(couture).not_to be_nil
        expect(couture[:showtimes].first[:language]).to eq("VOSE")
      end
    end

    context "empty HTML" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new("").parse }.to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end
  end
end
