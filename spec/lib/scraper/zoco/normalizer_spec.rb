# frozen_string_literal: true

require_relative '../../../../lib/scraper/zoco/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Zoco::Normalizer do
  describe "#normalize" do
    let(:normalizer) { described_class.new }

    let(:base_movie) do
      {
        title: "Calle Málaga",
        poster: "https://cineszocomajadahonda.org/calle.jpg",
        directors: "Maryam Touzani, Nabil Ayouch",
        duration: "116 minutos",
        description: "Una pelicula.",
        language: "Original en castellano y árabe",
        showtimes: [ { date: "21-05-2026", time: "16:00" }, { date: "23-05-2026", time: "22:00" } ]
      }
    end

    context "valid input" do
      it "returns cleaned movie" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:title]).to eq("Calle Málaga")
        expect(result[:directors]).to eq([ "Maryam Touzani", "Nabil Ayouch" ])
        expect(result[:duration]).to eq(116)
        expect(result[:language]).to eq(:vo)
        expect(result[:showtimes]).to eq([
          { date: Time.utc(2026, 5, 21, 16, 0) },
          { date: Time.utc(2026, 5, 23, 22, 0) }
        ])
      end
    end

    context "language mapping" do
      it "detects :vose when subtitles are mentioned" do
        movie = base_movie.merge(language: "Original en francés con subtítulos en castellano")
        expect(normalizer.normalize([ movie ]).first[:language]).to eq(:vose)
      end

      it "detects :dubbed" do
        movie = base_movie.merge(language: "Doblada en castellano")
        expect(normalizer.normalize([ movie ]).first[:language]).to eq(:dubbed)
      end

      it "tolerates typos like 'Dobalada'" do
        movie = base_movie.merge(language: "Dobalada en castellano")
        expect(normalizer.normalize([ movie ]).first[:language]).to eq(:dubbed)
      end

      it "raises UnknownLanguageError for unknown labels" do
        movie = base_movie.merge(language: "Klingon")
        expect { normalizer.normalize([ movie ]) }.to raise_error(Scraper::UnknownLanguageError)
      end

      it "raises UnknownLanguageError for blank language" do
        movie = base_movie.merge(language: nil)
        expect { normalizer.normalize([ movie ]) }.to raise_error(Scraper::UnknownLanguageError)
      end
    end

    context "title suffix" do
      it "strips trailing VOSE" do
        movie = base_movie.merge(title: "El amigo inesperado VOSE")
        expect(normalizer.normalize([ movie ]).first[:title]).to eq("El amigo inesperado")
      end

      it "strips trailing V.O.S." do
        movie = base_movie.merge(title: "Love Me Tender V.O.S.")
        expect(normalizer.normalize([ movie ]).first[:title]).to eq("Love Me Tender")
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
  end
end
