# frozen_string_literal: true

require_relative '../../../../lib/scraper/zoco/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Zoco::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'zoco') }

  describe "#parse" do
    context "valid movie page" do
      let(:html) { File.read(File.join(fixtures_path, 'movie.html')) }

      it "parses the core movie fields" do
        movie = described_class.new(html).parse
        expect(movie[:title]).to eq("Calle Málaga")
        expect(movie[:directors]).to eq("Maryam Touzani")
        expect(movie[:duration]).to eq("116 minutos")
        expect(movie[:language]).to eq("Original en castellano y árabe")
        expect(movie[:poster]).to include("calle_malaga")
      end

      it "parses all session date+time pairs" do
        movie = described_class.new(html).parse
        expect(movie[:showtimes]).not_to be_empty
        expect(movie[:showtimes]).to all(include(:date, :time))
        expect(movie[:showtimes].first).to include(date: "21-05-2026", time: "16:00")
        expect(movie[:showtimes].map { |s| s[:date] }.uniq.size).to be >= 5
      end
    end

    context "empty html" do
      it "raises InvalidMovieError" do
        expect { described_class.new("").parse }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
