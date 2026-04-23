# frozen_string_literal: true

require_relative '../../../lib/scraper/normalizer'
require_relative '../../../lib/scraper'

RSpec.describe Scraper::Normalizer do
  describe ".normalize" do
    context "when passing an array of non clean movies" do
      let(:input) do
        [{
          poster: "media/Peliculas/Cartel/pelicula.jpg",
          title: "PRIME CRIME: A TRUE STORY",
          directors: " de Víctor García León ",
          language: "Versión Original Castellano",
          duration: " Duración 101 minutos ",
          showtimes: ["\n               15:50\n            "]
        },
        {
          poster: "https://subdomain.domain.com/imagenes/hash.jpg",
          title: "EL CRISTAL OSCURO [WILDER CINEMA]",
          directors: " de Lluís Galter, Eduardo Casanova, Màrius Sánchez ",
          language: "Versión Original subtitulada a Castellano",
          duration: " Duración 123 minutos ",
          showtimes: ["\n" + "               16:00\n" + "            ", "\n" + "               18:00\n" + "            ", "\n" + "               22:45\n" + "            "]
        }]
      end

      it "returns the clean movies" do
        expect(described_class.normalize(input)).to match([{
          poster: nil,
          title: "PRIME CRIME: A TRUE STORY",
          directors: [ "Víctor García León" ],
          language: :vo,
          duration: 101,
          showtimes: [ Time.new(2026, 4, 23, 15, 50) ]
        },
        {
          poster: "https://subdomain.domain.com/imagenes/hash.jpg",
          title: "EL CRISTAL OSCURO [WILDER CINEMA]",
          directors: [ "Lluís Galter", "Eduardo Casanova", "Màrius Sánchez" ],
          language: :vose,
          duration: 123,
          showtimes: [ Time.new(2026, 4, 23, 16, 00), Time.new(2026, 4, 23, 18, 00), Time.new(2026, 4, 23, 22, 45) ]
        }])
      end
    end

    context "when passing an empty array" do
      it 'raises ArgumentError' do
        expect do
          described_class.normalize([])
        end.to raise_error ArgumentError, "Input array is empty."
      end
    end

    context "when not passing an array" do
      it 'raises ArgumentError' do
        expect do
          described_class.normalize("hello")
        end.to raise_error ArgumentError, "Input should be an array."
      end
    end
  end
end
