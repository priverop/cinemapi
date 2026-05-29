require_relative '../../../../lib/scraper/mooby/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Mooby::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures/mooby') }
  let(:html)          { File.read(File.join(fixtures_path, 'cartelera.html')) }

  describe "#parse" do
    subject(:movies) { described_class.new(html, "BAL-BALMES").parse }

    it "returns the target shop's movies" do
      expect(movies).not_to be_empty
    end

    it "excludes movies from other shops" do
      expect(movies.map { |m| m[:title] }).not_to include("Arenas Only Movie")
    end

    it "skips events flagged as Eventos (concerts)" do
      expect(movies.none? { |m| m[:title].to_s.include?("BTS") }).to be(true)
    end

    it "skips events with no performances" do
      expect(movies.map { |m| m[:title] }).not_to include("Estreno Futuro")
    end

    it "keeps each version as its own entry so the Importer can dedup by title" do
      michael = movies.select { |m| m[:title] == "Michael" }
      expect(michael.size).to eq(2)
      languages = michael.flat_map { |m| m[:showtimes].map { |s| s[:language] } }.uniq
      expect(languages).to contain_exactly("VOSE", "DOBLADA ESP")
    end

    it "extracts performances as YYYYMMDDhhmmss date strings" do
      michael = movies.find { |m| m[:title] == "Michael" && m[:showtimes].first[:language] == "VOSE" }
      expect(michael[:showtimes].map { |s| s[:date] }).to all(match(/\A\d{14}\z/))
      expect(michael[:showtimes].size).to eq(2)
    end

    it "falls back to VOSE for blank version when subtitles are present" do
      hokum = movies.find { |m| m[:title] == "Hokum" }
      expect(hokum[:showtimes].first[:language]).to eq("VOSE")
    end

    it "links each movie to its detail-page slug and poster via the cartelera grid" do
      michael = movies.find { |m| m[:title] == "Michael" }
      expect(michael[:imdbid]).to eq("tt104102")
      expect(michael[:slug]).to eq("/michael")
      expect(michael[:poster]).to eq("https://www.bizcochito.es/img/tt104102-ca-pos.webp")
    end

    it "falls back to a slugified name when the movie has no grid anchor" do
      corredora = movies.find { |m| m[:title] == "Corredora" }
      expect(corredora[:slug]).to eq("/corredora")
      expect(corredora[:poster]).to be_nil
    end

    context "when the shop code is unknown" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new(html, "BAL-NOPE").parse }
          .to raise_error(Scraper::MoviesNotFoundError)
      end
    end

    context "when window.shops is missing" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new("<html></html>", "BAL-BALMES").parse }
          .to raise_error(Scraper::MoviesNotFoundError)
      end
    end
  end
end
