# frozen_string_literal: true

require_relative '../../../../lib/scraper/golem/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Golem::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures/golem') }

  describe "#parse" do
    context "valid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'day.html')) }

      it "returns the right amount of movies" do
        parser = described_class.new(html)
        expect(parser.parse.count).to eq(9)
      end

      it "skips non-movie containers (ciclos, eventos)" do
        parser = described_class.new(html)
        titles = parser.parse.map { |m| m[:title] }
        expect(titles).to all(be_present)
        expect(titles).not_to include("Espacio Educativo Aula Golem", "GO! MADRID")
      end

      it "returns a valid parsed movie with VOSE marker" do
        parser = described_class.new(html)
        movie = parser.parse.first
        expect(movie[:title]).to eq("El Amigo Inesperado (V.O.S.E.)")
        expect(movie[:poster]).to eq("/golem/carteles/2026/April/1776857306.jpg")
        expect(movie[:language]).to eq("vose")
        expect(movie[:showtimes]).to eq(%w[16:00 20:20])
      end

      it "marks movie without VOSE suffix as vo" do
        parser = described_class.new(html)
        hangar = parser.parse.find { |m| m[:title].include?("Hangar") }
        expect(hangar[:title]).to eq("Hangar Rojo")
        expect(hangar[:language]).to eq("vo")
      end
    end

    context "empty html" do
      it "raises MoviesNotFoundError" do
        parser = described_class.new("")
        expect { parser.parse }.to raise_error(Scraper::MoviesNotFoundError, "Movies not found.")
      end
    end
  end
end
