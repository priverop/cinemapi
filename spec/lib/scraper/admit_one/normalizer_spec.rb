# frozen_string_literal: true

require_relative '../../../../lib/scraper/admit_one/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::AdmitOne::Normalizer do
  let(:normalizer) { described_class.new }

  describe "#normalize" do
    context "valid input" do
      let(:input) do
        [ {
          title: "Iron Maiden: Burning Ambition (VOSE)",
          directors: "Malcolm Venville",
          duration: "105 min.",
          genres: [ "Documental", "Biográfico" ],
          poster: "https://www.bizcochito.es/poster.webp",
          description: "  La historia de 50 años.  ",
          showtimes: [
            { date: "20260520 22:30", language: "V.O. SUB. CASTELLANO" },
            { date: "20260521 20:00", language: "CASTELLANO" }
          ]
        } ]
      end

      it "normalizes a movie" do
        result = normalizer.normalize(input).first
        expect(result[:title]).to eq("Iron Maiden: Burning Ambition")
        expect(result[:directors]).to eq([ "Malcolm Venville" ])
        expect(result[:duration]).to eq(105)
        expect(result[:genres]).to eq([ "Documental", "Biográfico" ])
        expect(result[:poster]).to eq("https://www.bizcochito.es/poster.webp")
        expect(result[:description]).to eq("La historia de 50 años.")
        expect(result[:language]).to be_nil
        expect(result[:showtimes]).to eq([
          { date: Time.utc(2026, 5, 20, 22, 30), language: :vose },
          { date: Time.utc(2026, 5, 21, 20, 0), language: :vo }
        ])
      end
    end

    context "language mapping" do
      def normalize_lang(label)
        normalizer.send(:normalize_language_from_map, label, described_class::LANGUAGE_MAP)
      end

      it "maps known labels" do
        expect(normalize_lang("VOSE")).to eq(:vose)
        expect(normalize_lang("VOSC")).to eq(:vose)
        expect(normalize_lang("VOSI")).to eq(:vosi)
        expect(normalize_lang("V.O. SUB. CASTELLANO")).to eq(:vose)
        expect(normalize_lang("CASTELLANO")).to eq(:vo)
        expect(normalize_lang("CASTELLÀ")).to eq(:vo)
        expect(normalize_lang("CATALÀ")).to eq(:vo)
        expect(normalize_lang("DIG")).to eq(:vo)
      end

      it "raises UnknownLanguageError for blank or unknown labels" do
        expect { normalize_lang(nil) }.to raise_error(Scraper::UnknownLanguageError)
        expect { normalize_lang("BANANA") }.to raise_error(Scraper::UnknownLanguageError)
      end
    end

    context "invalid input" do
      it "raises on non-array" do
        expect { normalizer.normalize("nope") }.to raise_error(ArgumentError, "Input should be an array.")
      end

      it "raises on empty array" do
        expect { normalizer.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
      end

      it "raises on empty title" do
        bad = [ { title: "", directors: nil, duration: nil, genres: [], poster: nil, description: nil, showtimes: [] } ]
        expect { normalizer.normalize(bad) }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
