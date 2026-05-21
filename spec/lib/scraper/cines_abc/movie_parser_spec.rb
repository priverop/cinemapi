# frozen_string_literal: true

require_relative '../../../../lib/scraper/cines_abc/movie_parser'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::CinesAbc::MovieParser do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'cines_abc') }

  describe "#parse" do
    context "valid ficha page" do
      let(:html) { File.read(File.join(fixtures_path, 'el_saler_ficha.html')) }

      it "parses the core movie fields" do
        movie = described_class.new(html).parse
        expect(movie[:title]).to eq("EL AMIGO INESPERADO")
        expect(movie[:duration]).to eq("102min")
        expect(movie[:genres]).to eq([ "COMEDIA" ])
        expect(movie[:poster]).to include("JPg001h9.jpg")
        expect(movie[:description]).to include("Baptiste")
      end

      it "parses all showtime entries with per-showtime language" do
        movie = described_class.new(html).parse
        expect(movie[:showtimes]).not_to be_empty
        expect(movie[:showtimes]).to all(include(:date, :time, :language))
        expect(movie[:showtimes]).to include(a_hash_including(date: "21/05/2026", time: "22:45"))
        languages = movie[:showtimes].map { |s| s[:language] }
        expect(languages).to include("(VOSE)")
        expect(languages).to include("")
      end
    end

    context "empty html" do
      it "raises InvalidMovieError" do
        expect { described_class.new("").parse }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
