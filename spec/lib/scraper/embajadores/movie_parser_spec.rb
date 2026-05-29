# frozen_string_literal: true

require_relative '../../../../lib/scraper/embajadores/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Embajadores::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'embajadores') }
  let(:html) { File.read(File.join(fixtures_path, 'cartelera.html')) }
  let(:parser) { described_class.new(html) }

  describe "#parse" do
    context "valid HTML" do
      it "returns multiple movies" do
        expect(parser.parse.count).to be > 1
      end

      it "each movie has required keys" do
        expect(parser.parse.first).to include(:title, :director, :duration, :language, :poster, :showtimes)
      end

      it "extracts title as non-empty string" do
        title = parser.parse.first[:title]
        expect(title).to be_a(String)
        expect(title).not_to be_empty
      end

      it "extracts poster as a URL string" do
        expect(parser.parse.first[:poster]).to be_a(String).and include("http")
      end

      it "includes movies with V.O.S.E. language" do
        expect(parser.parse.any? { |m| m[:language] == "V.O.S.E." }).to be true
      end

      it "includes movies with V.E. language" do
        expect(parser.parse.any? { |m| m[:language] == "V.E." }).to be true
      end

      it "showtimes are arrays of hashes with :time and :url" do
        showtime = parser.parse.first[:showtimes].first
        expect(showtime).to include(:time, :url)
        expect(showtime[:time]).to match(/\A\d{2}:\d{2}\z/)
        expect(showtime[:url]).to include("reservaentradas.com")
      end

      it "showtimes include both venue slugs" do
        all_urls = parser.parse.flat_map { |m| m[:showtimes].map { |s| s[:url] } }
        expect(all_urls.any? { |u| u.include?("cineembajadores") && !u.include?("cineembajadoresrio") }).to be true
        expect(all_urls.any? { |u| u.include?("cineembajadoresrio") }).to be true
      end
    end

    context "empty HTML" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new("<html></html>").parse }
          .to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end
  end
end
