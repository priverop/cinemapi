# frozen_string_literal: true

require_relative '../../../../lib/scraper/cines_abc/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::CinesAbc::Normalizer do
  describe "#normalize" do
    let(:normalizer) { described_class.new }

    let(:base_movie) do
      {
        title: "EL AMIGO INESPERADO",
        poster: "https://elsaler.cinesabc.com/poster.jpg",
        description: "Baptiste es un imitador.",
        duration: "102min",
        genres: [ "COMEDIA" ],
        showtimes: [
          { date: "21/05/2026", time: "22:45h", language: "" },
          { date: "25/05/2026", time: "22:45h", language: "(VOSE)" }
        ]
      }
    end

    context "valid input" do
      it "returns cleaned movie" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:title]).to eq("El Amigo Inesperado")
        expect(result[:duration]).to eq(102)
        expect(result[:genres]).to eq([ "COMEDIA" ])
        expect(result[:description]).to eq("Baptiste es un imitador.")
      end

      it "builds showtimes with parsed datetime and language" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:showtimes]).to eq([
          { date: Time.utc(2026, 5, 21, 22, 45), language: :dubbed },
          { date: Time.utc(2026, 5, 25, 22, 45), language: :vose }
        ])
      end

      it "does not set a movie-level language" do
        result = normalizer.normalize([ base_movie ]).first
        expect(result[:language]).to be_nil
      end
    end

    context "language mapping" do
      it "maps (VOSE) to :vose" do
        movie = base_movie.merge(showtimes: [ { date: "21/05/2026", time: "22:45h", language: "(VOSE)" } ])
        expect(normalizer.normalize([ movie ]).first[:showtimes].first[:language]).to eq(:vose)
      end

      it "maps blank tag to :dubbed" do
        movie = base_movie.merge(showtimes: [ { date: "21/05/2026", time: "22:45h", language: "" } ])
        expect(normalizer.normalize([ movie ]).first[:showtimes].first[:language]).to eq(:dubbed)
      end

      it "maps nil tag to :dubbed" do
        movie = base_movie.merge(showtimes: [ { date: "21/05/2026", time: "22:45h", language: nil } ])
        expect(normalizer.normalize([ movie ]).first[:showtimes].first[:language]).to eq(:dubbed)
      end

      it "maps non-VOSE tags (format markers like (3D), (IMAX)) to :dubbed" do
        movie = base_movie.merge(showtimes: [ { date: "21/05/2026", time: "22:45h", language: "(3D)" } ])
        expect(normalizer.normalize([ movie ]).first[:showtimes].first[:language]).to eq(:dubbed)
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
        movie = base_movie.merge(title: "  ")
        expect { normalizer.normalize([ movie ]) }.to raise_error(Scraper::InvalidMovieError)
      end
    end
  end
end
