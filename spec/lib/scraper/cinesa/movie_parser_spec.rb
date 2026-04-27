# frozen_string_literal: true

require_relative '../../../../lib/scraper/cinesa/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Cinesa::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures/cinesa') }

  describe ".parse" do
    context "valid JSON" do
      let(:input) { File.read(File.join(fixtures_path, 'pio.json')) }

      it "returns the right amount of movies" do
        parser = described_class.new(input)
        pp parser.parse
        expect(parser.parse.count).to eq(8)
      end

      it "returns a valid parsed movie" do
        skip
        parser = described_class.new(input)
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

    context "empty input" do
      it 'raises JSON::ParseError' do
        expect do
          described_class.new("")
        end.to raise_error JSON::ParserError, /unexpected/
      end
    end
  end
end
