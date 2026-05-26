# frozen_string_literal: true

require_relative '../../../../lib/scraper/ocine/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Ocine::Normalizer do
  let(:normalizer) { described_class.new(base_url: "https://ocineurbanxmadrid.es") }

  let(:base_movie) do
    {
      movie_id:    9904,
      title:       "El Diablo viste de Prada 2",
      duration:    "118",
      genre:       "Comedia",
      description: "Veinte años después...",
      language:    :dubbed,
      showtimes:   [
        { date: "2026-05-22", time: "16:00:00" },
        { date: "2026-05-23", time: "18:20:00" }
      ]
    }
  end

  describe "#normalize" do
    context "valid input" do
      it "returns cleaned movie hash" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:title]).to eq("El Diablo viste de Prada 2")
        expect(result[:duration]).to eq(118)
        expect(result[:genres]).to eq([ "Comedia" ])
        expect(result[:description]).to eq("Veinte años después...")
        expect(result[:directors]).to eq([])
      end

      it "builds poster URL from movie_id on the tickets subdomain" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:poster]).to eq("https://tickets.ocineurbanxmadrid.es/images/pelicules/9904.jpg")
      end

      it "passes language at movie level" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:language]).to eq(:dubbed)
      end

      it "parses showtimes into Time objects" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:showtimes]).to eq([
          { date: Time.utc(2026, 5, 22, 16, 0) },
          { date: Time.utc(2026, 5, 23, 18, 20) }
        ])
      end

      it "strips (VOSE) suffix from title" do
        movie = base_movie.merge(title: "El Castillo en el Cielo (VOSE)  (40º Aniversario)", language: :vose)
        result = normalizer.normalize([ movie ]).first
        expect(result[:title]).to eq("El Castillo en el Cielo (40º Aniversario)")
      end
    end

    context "empty title" do
      it "raises InvalidMovieError" do
        expect { normalizer.normalize([ base_movie.merge(title: "  ") ]) }
          .to raise_error(Scraper::InvalidMovieError)
      end
    end

    context "empty array" do
      it "raises ArgumentError" do
        expect { normalizer.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
      end
    end

    context "non-array" do
      it "raises ArgumentError" do
        expect { normalizer.normalize("nope") }.to raise_error(ArgumentError, "Input should be an array.")
      end
    end

    context "unknown language" do
      it "raises UnknownLanguageError for nil language" do
        expect { normalizer.normalize([ base_movie.merge(language: nil) ]) }
          .to raise_error(Scraper::UnknownLanguageError)
      end
    end
  end
end
