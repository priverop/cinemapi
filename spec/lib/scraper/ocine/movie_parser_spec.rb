# frozen_string_literal: true

require_relative '../../../../lib/scraper/ocine/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Ocine::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'ocine') }
  let(:json)          { File.read(File.join(fixtures_path, 'cartelera.json')) }

  describe "#parse" do
    context "valid cartelera json" do
      it "returns movies from data[] and vose[] combined" do
        movies = described_class.new(json).parse
        titles = movies.map { |m| m[:title] }
        expect(titles).to include("El Diablo viste de Prada 2")
        expect(titles).to include("El Castillo en el Cielo (VOSE)  (40º Aniversario)")
      end

      it "ignores estrenos (upcoming releases without showtimes)" do
        movies = described_class.new(json).parse
        expect(movies.map { |m| m[:title] }).not_to include("El Drama")
      end

      it "tags data[] movies with :dubbed and vose[] movies with :vose" do
        movies = described_class.new(json).parse
        prada = movies.find { |m| m[:title].start_with?("El Diablo") }
        castillo = movies.find { |m| m[:title].include?("Castillo") }
        expect(prada[:language]).to eq(:dubbed)
        expect(castillo[:language]).to eq(:vose)
      end

      it "extracts core movie fields" do
        movie = described_class.new(json).parse.find { |m| m[:title].start_with?("El Diablo") }
        expect(movie[:duration]).to eq("118")
        expect(movie[:genre]).to eq("Comedia")
        expect(movie[:description]).to include("Meryl Streep")
        expect(movie[:movie_id]).to eq(9904)
      end

      it "extracts showtimes as date+time pairs" do
        movie = described_class.new(json).parse.find { |m| m[:title].start_with?("El Diablo") }
        expect(movie[:showtimes]).not_to be_empty
        expect(movie[:showtimes]).to all(include(:date, :time))
        expect(movie[:showtimes].first[:date]).to eq("2026-05-22")
        expect(movie[:showtimes].first[:time]).to eq("16:00:00")
      end
    end

    context "empty json" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new('{"data":[],"vose":[]}').parse }
          .to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end

    context "malformed json" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new("not json").parse }
          .to raise_error(Scraper::MoviesNotFoundError)
      end
    end
  end
end
