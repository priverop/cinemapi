# frozen_string_literal: true

require_relative '../../../../lib/scraper/renoir/normalizer'
require_relative '../../../../lib/scraper'

require 'spec_helper'

RSpec.describe Scraper::Renoir::Normalizer do
  describe "#normalize" do
    let(:today) { Date.today.strftime("%Y-%m-%d") }
    let(:normalizer) { described_class.new(today) }

    context "when passing an array of non clean movies" do
      let(:input) do
        [ {
          poster: "media/Peliculas/Cartel/pelicula.jpg",
          title: "PRIME CRIME: A TRUE STORY",
          directors: " de Víctor García León ",
          language: "Versión Original Castellano",
          duration: " Duración 101 minutos ",
          showtimes: [ "\n               15:50\n            " ]
        },
        {
          poster: "https://subdomain.domain.com/imagenes/hash.jpg",
          title: "EL CRISTAL OSCURO [WILDER CINEMA]",
          directors: " de Lluís Galter, Eduardo Casanova, Màrius Sánchez ",
          language: "Versión Original subtitulada a Castellano",
          duration: " Duración 123 minutos ",
          showtimes: [ "\n" + "               16:00\n" + "            ", "\n" + "               18:00\n" + "            ", "\n" + "               22:45\n" + "            " ]
        } ]
      end

      it "returns the clean movies" do
        expect(normalizer.normalize(input)).to match([ {
          poster: nil,
          title: "PRIME CRIME: A TRUE STORY",
          directors: [ "Víctor García León" ],
          language: :vo,
          duration: 101,
          showtimes: [ Time.new(Date.today.year, Date.today.month, Date.today.day, 15, 50) ]
        },
        {
          poster: "https://subdomain.domain.com/imagenes/hash.jpg",
          title: "EL CRISTAL OSCURO [WILDER CINEMA]",
          directors: [ "Lluís Galter", "Eduardo Casanova", "Màrius Sánchez" ],
          language: :vose,
          duration: 123,
          showtimes: [ Time.new(Date.today.year, Date.today.month, Date.today.day, 16, 00), Time.new(Date.today.year, Date.today.month, Date.today.day, 18, 00), Time.new(Date.today.year, Date.today.month, Date.today.day, 22, 45) ]
        } ])
      end
    end

    context "when passing an empty array" do
      it 'raises ArgumentError' do
        expect do
          normalizer.normalize([])
        end.to raise_error ArgumentError, "Input array is empty."
      end
    end

    context "when not passing an array" do
      it 'raises ArgumentError' do
        expect do
          normalizer.normalize("hello")
        end.to raise_error ArgumentError, "Input should be an array."
      end
    end
  end
end
