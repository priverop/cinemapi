# frozen_string_literal: true

require_relative '../../../../lib/scraper/mk2/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Mk2::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'mk2') }
  let(:html) { File.read(File.join(fixtures_path, 'cartelera.html')) }

  describe "#parse" do
    context "day 0 from fixture" do
      let(:parser) { described_class.new(html, 0) }

      it "returns 10 movies" do
        expect(parser.parse.count).to eq(10)
      end

      it "each movie has required keys" do
        expect(parser.parse.first).to include(:title, :director, :duration, :language, :poster, :showtimes)
      end

      it "extracts title as a non-empty string" do
        title = parser.parse.first[:title]
        expect(title).to be_a(String)
        expect(title).not_to be_empty
      end

      it "detects dubbed language when etiqueta-vose absent" do
        expect(parser.parse.any? { |m| m[:language] == :dubbed }).to be true
      end

      it "detects vose language when etiqueta-vose present" do
        expect(parser.parse.any? { |m| m[:language] == :vose }).to be true
      end

      it "showtimes are non-empty arrays of strings" do
        movie = parser.parse.first
        expect(movie[:showtimes]).to be_an(Array)
        expect(movie[:showtimes]).not_to be_empty
        expect(movie[:showtimes].first).to be_a(String)
      end

      it "showtimes do not contain VOSE text" do
        all_times = parser.parse.flat_map { |m| m[:showtimes] }
        expect(all_times).to all(match(/\A\d{2}:\d{2}\z/))
      end

      it "poster is a relative path string" do
        expect(parser.parse.first[:poster]).to be_a(String).and include("data/fotos")
      end
    end

    context "container exists but has no .peli elements" do
      let(:html) do
        <<~HTML
          <div class="contenedor_cines cines-0"></div>
        HTML
      end

      it "raises MoviesNotFoundError" do
        expect { described_class.new(html, 0).parse }.to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end

    context "day container does not exist" do
      it "raises MoviesNotFoundError" do
        expect { described_class.new("<html></html>", 99).parse }.to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end
  end
end
