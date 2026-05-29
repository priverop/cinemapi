# frozen_string_literal: true

require_relative '../../../../lib/scraper/mk2/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Mk2::Normalizer do
  let(:date) { Date.new(2026, 5, 13) }
  let(:normalizer) { described_class.new(date) }

  let(:valid_movie) do
    {
      title: "Yo no moriré de amor",
      director: "de Marta Matute",
      duration: "94 minutos",
      language: :dubbed,
      poster: "data/fotos/yo-no-morire-de-amor-afiche.jpg",
      showtimes: [ "19:30", "21:30" ]
    }
  end

  describe "#normalize" do
    it "raises ArgumentError when not an array" do
      expect { normalizer.normalize({}) }.to raise_error(ArgumentError, "Input should be an array.")
    end

    it "raises ArgumentError when array is empty" do
      expect { normalizer.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
    end

    it "returns one normalized movie" do
      expect(normalizer.normalize([ valid_movie ]).size).to eq(1)
    end

    it "normalizes title (titleize, strips VOSE suffix)" do
      result = normalizer.normalize([ valid_movie.merge(title: "couture (VOSE)") ])
      expect(result.first[:title]).to eq("Couture")
    end

    it "raises InvalidMovieError for blank title" do
      expect { normalizer.normalize([ valid_movie.merge(title: "") ]) }
        .to raise_error(Scraper::InvalidMovieError)
    end

    it "normalizes director: strips 'de ', returns array" do
      expect(normalizer.normalize([ valid_movie ]).first[:directors]).to eq([ "Marta Matute" ])
    end

    it "returns empty directors array when blank" do
      expect(normalizer.normalize([ valid_movie.merge(director: "") ]).first[:directors]).to eq([])
    end

    it "normalizes duration to integer" do
      expect(normalizer.normalize([ valid_movie ]).first[:duration]).to eq(94)
    end

    it "returns nil duration when blank" do
      expect(normalizer.normalize([ valid_movie.merge(duration: "") ]).first[:duration]).to be_nil
    end

    it "passes through language" do
      expect(normalizer.normalize([ valid_movie ]).first[:language]).to eq(:dubbed)
    end

    it "normalizes relative poster to absolute URL" do
      poster = normalizer.normalize([ valid_movie ]).first[:poster]
      expect(poster).to start_with("https://www.cinepazmadrid.es/")
      expect(poster).to include("yo-no-morire-de-amor-afiche.jpg")
    end

    it "returns nil poster when blank" do
      expect(normalizer.normalize([ valid_movie.merge(poster: nil) ]).first[:poster]).to be_nil
    end

    it "normalizes showtimes to Time objects" do
      showtimes = normalizer.normalize([ valid_movie ]).first[:showtimes]
      expect(showtimes.size).to eq(2)
      expect(showtimes.first[:date]).to be_a(Time)
    end

    it "showtimes include the correct date" do
      showtimes = normalizer.normalize([ valid_movie ]).first[:showtimes]
      expect(showtimes.first[:date].strftime("%Y-%m-%d")).to eq("2026-05-13")
    end

    it "returns empty showtimes when blank" do
      expect(normalizer.normalize([ valid_movie.merge(showtimes: []) ]).first[:showtimes]).to eq([])
    end
  end
end
