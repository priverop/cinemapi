require_relative '../../../../lib/scraper/mooby/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Mooby::Normalizer do
  let(:normalizer) { described_class.new }

  describe "#normalize" do
    context "valid input" do
      let(:input) do
        [ {
          title: "Michael (VOSE)",
          imdbid: "tt104102",
          slug: "/michael",
          directors: "Antoine Fuqua, Jane Doe",
          duration: "140 min.",
          genres: "Drama, Musical",
          poster: "https://www.bizcochito.es/img/tt104102-ca-pos.webp",
          description: "  La vida del rei del pop.  ",
          showtimes: [
            { date: "20260527212000", language: "VOSE" },
            { date: "20260528180000", language: "DOBLADA ESP" }
          ]
        } ]
      end

      it "normalizes a movie" do
        result = normalizer.normalize(input).first
        expect(result[:title]).to eq("Michael")
        expect(result[:directors]).to eq([ "Antoine Fuqua", "Jane Doe" ])
        expect(result[:duration]).to eq(140)
        expect(result[:genres]).to eq([ "Drama", "Musical" ])
        expect(result[:poster]).to eq("https://www.bizcochito.es/img/tt104102-ca-pos.webp")
        expect(result[:description]).to eq("La vida del rei del pop.")
        expect(result[:language]).to be_nil
        expect(result[:showtimes]).to eq([
          { date: Time.utc(2026, 5, 27, 21, 20), language: :vose },
          { date: Time.utc(2026, 5, 28, 18, 0), language: :dubbed }
        ])
      end
    end

    context "missing metadata" do
      let(:input) do
        [ {
          title: "Sin Datos",
          directors: nil, duration: nil, genres: nil, poster: nil, description: nil,
          showtimes: [ { date: "20260527200000", language: "ESP" } ]
        } ]
      end

      it "coerces absent fields to empty values without raising" do
        result = normalizer.normalize(input).first
        expect(result[:directors]).to eq([])
        expect(result[:genres]).to eq([])
        expect(result[:duration]).to be_nil
        expect(result[:description]).to be_nil
      end
    end

    context "language mapping" do
      def normalize_lang(label)
        normalizer.send(:normalize_language_from_map, label, described_class::LANGUAGE_MAP)
      end

      it "maps known labels" do
        expect(normalize_lang("VOSE")).to eq(:vose)
        expect(normalize_lang("VOSE ATMOS")).to eq(:vose)
        expect(normalize_lang("DOBLADA ESP")).to eq(:dubbed)
        expect(normalize_lang("DOBLADA ESP ATMOS")).to eq(:dubbed)
        expect(normalize_lang("DOBLADA CAT")).to eq(:dubbed)
        expect(normalize_lang("ESP")).to eq(:vo)
        expect(normalize_lang("CAT")).to eq(:vo)
      end

      it "raises UnknownLanguageError for blank or unknown labels" do
        expect { normalize_lang(nil) }.to raise_error(Scraper::UnknownLanguageError)
        expect { normalize_lang("BANANA") }.to raise_error(Scraper::UnknownLanguageError)
      end

      it "raises on VOSI (unsupported; only seen on skipped concerts)" do
        expect { normalize_lang("VOSI") }.to raise_error(Scraper::UnknownLanguageError)
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
        bad = [ { title: "", directors: nil, duration: nil, genres: nil, poster: nil, description: nil, showtimes: [] } ]
        expect { normalizer.normalize(bad) }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
