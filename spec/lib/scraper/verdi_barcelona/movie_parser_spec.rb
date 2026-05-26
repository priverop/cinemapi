# frozen_string_literal: true

require_relative '../../../../lib/scraper/verdi_barcelona/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::VerdiBarcelona::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'verdi_barcelona') }

  describe "#parse" do
    context "valid movie json" do
      let(:json) { File.read(File.join(fixtures_path, 'dragon_ball.json')) }

      it "parses the core movie fields from the localized title" do
        movie = described_class.new(json).parse
        expect(movie[:title]).to eq("Dragon Ball Super: Super Hero")
        expect(movie[:duration]).to eq("120")
        expect(movie[:directors]).to eq([ "Tetsuro Kodama" ])
        expect(movie[:genres]).to eq([ "Acción", "Animación", "Aventura", "Fantasía" ])
        expect(movie[:description]).to include("Goku")
      end

      it "flattens every event performance into a showtime carrying the event version" do
        movie = described_class.new(json).parse
        expect(movie[:showtimes]).to contain_exactly(
          { date: "20260530113000", language: "CASTELLANO" },
          { date: "20260531113000", language: "CASTELLANO" },
          { date: "20260530160000", language: "CATALÁN" },
          { date: "20260531160000", language: "CATALÁN" }
        )
      end

      it "ignores events that have no performances" do
        movie = described_class.new(json).parse
        expect(movie[:showtimes].map { |s| s[:language] }).not_to include("V.O. SUB. CASTELLANO")
      end
    end

    context "json without a result" do
      it "raises InvalidMovieError" do
        expect { described_class.new('{"error":"not found"}').parse }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
