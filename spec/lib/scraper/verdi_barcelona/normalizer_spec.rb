# frozen_string_literal: true

require_relative '../../../../lib/scraper/verdi_barcelona/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::VerdiBarcelona::Normalizer do
  let(:normalizer) { described_class.new }

  let(:base_movie) do
    {
      title: "Dragon Ball Super: Super Hero",
      directors: [ "Tetsuro Kodama" ],
      duration: "120",
      genres: [ "Acción", "Animación" ],
      description: "  El Ejército   de la Cinta Roja.  ",
      poster: "https://www.bizcochito.es/img/tt14614892-ca-pos.webp",
      showtimes: [
        { date: "20260530113000", language: "CASTELLANO" },
        { date: "20260530160000", language: "V.O. SUB. CASTELLANO" }
      ]
    }
  end

  describe "#normalize" do
    context "valid input" do
      it "returns the cleaned movie fields" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:title]).to eq("Dragon Ball Super: Super Hero")
        expect(result[:duration]).to eq(120)
        expect(result[:genres]).to eq([ "Acción", "Animación" ])
        expect(result[:description]).to eq("El Ejército de la Cinta Roja.")
        expect(result[:poster]).to eq("https://www.bizcochito.es/img/tt14614892-ca-pos.webp")
      end

      it "builds showtimes with parsed datetime and per-showtime language" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:showtimes]).to eq([
          { date: Time.utc(2026, 5, 30, 11, 30), language: :vo },
          { date: Time.utc(2026, 5, 30, 16, 0), language: :vose }
        ])
      end

      it "does not set a movie-level language" do
        expect(normalizer.normalize([ base_movie ]).first[:language]).to be_nil
      end
    end

    context "language mapping" do
      def language_for(version)
        movie = base_movie.merge(showtimes: [ { date: "20260530113000", language: version } ])
        normalizer.normalize([ movie ]).first[:showtimes].first[:language]
      end

      it "maps V.O. SUB. CASTELLANO to :vose" do
        expect(language_for("V.O. SUB. CASTELLANO")).to eq(:vose)
      end

      it "maps CASTELLANO to :vo" do
        expect(language_for("CASTELLANO")).to eq(:vo)
      end

      it "maps CATALÁN to :vo" do
        expect(language_for("CATALÁN")).to eq(:vo)
      end

      it "maps VARIOS to :vo" do
        expect(language_for("VARIOS")).to eq(:vo)
      end

      it "raises UnknownLanguageError for a blank version" do
        expect { language_for("") }.to raise_error(Scraper::UnknownLanguageError)
      end

      it "raises UnknownLanguageError for an unrecognized version" do
        expect { language_for("DOBLADA") }.to raise_error(Scraper::UnknownLanguageError)
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

    context "empty title" do
      it "raises InvalidMovieError" do
        expect { normalizer.normalize([ base_movie.merge(title: "  ") ]) }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
