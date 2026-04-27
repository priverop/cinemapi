# frozen_string_literal: true

require_relative '../../../lib/scraper/movie_parser'
require_relative '../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../', __dir__), 'fixtures') }

  describe ".parse" do
    context "valid HTML" do
      let(:html) { File.read(File.join(fixtures_path, 'princesa.html')) }

      it "returns the right amount of movies" do
        parser = described_class.new(html)
        expect(parser.parse.count).to eq(13)
      end

      it "returns a valid parsed movie" do
        parser = described_class.new(html)
        expect(parser.parse.first).to match({
          title: "ALTAS CAPACIDADES",
          directors: " de Víctor García León ",
          duration: " Duración 101 minutos ",
          language: "Versión Original Castellano",
          poster: "https://media.pillalas.com/imagenes/726afb526abffa83d22d791f6bb1a5c2569f3d5a548c994a3c4d94a4c257992f931f1da5.jpg",
          showtimes: [ "\n               15:50\n            " ]
        })
      end
    end

    context "empty html" do
      it 'raises ParsedMoviesNotFoundError' do
        parser = described_class.new("")
        expect do
          parser.parse
        end.to raise_error Scraper::MoviesNotFoundError, "Movies not found."
      end
    end
  end
end
