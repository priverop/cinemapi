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
        expect(parser.parse.count).to eq(8)
      end

      it "returns a valid parsed movie" do
        parser = described_class.new(input)
        expect(parser.parse.last).to match({
          description: "El profesor de ciencias Ryland Grace (Ryan Gosling) se despierta en una nave espacial a años luz de casa sin recordar quién es ni cómo ha llegado hasta allí. A medida que recupera la memoria, empieza a descubrir su misión: resolver el enigma de la misteriosa sustancia que provoca la extinción del sol. Deberá recurrir a sus conocimientos científicos y a sus ideas poco ortodoxas para salvar todo lo que hay en la Tierra de la extinción... pero una amistad inesperada significa que quizá no tenga que hacerlo solo.",
          directors: [ { "givenName" => "Phil", "familyName" => "Lord", "middleName" => nil }, { "givenName" => "Christopher", "familyName" => "Miller", "middleName" => nil } ],
          duration: 156,
          genres: [ "Acción", "Aventura", "Ciencia ficción" ],
          poster_id: "f741e25d-2e02-44e5-bc0f-5460117e540a",
          showtimes: [ { date: "2026-04-27T17:45:00+02:00", language: [ "Vose" ] }, { date: "2026-04-27T21:20:00+02:00", language: [] } ],
          title: "Proyecto Salvación",
          trailer: "https://www.youtube.com/watch?v=in-lUuKi0eE"
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
