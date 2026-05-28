# frozen_string_literal: true

require_relative '../../../../lib/scraper/embajadores/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Embajadores::Normalizer do
  let(:date) { Date.new(2026, 5, 13) }
  let(:cabeza) { described_class.new(date, "cineembajadores") }
  let(:rio)    { described_class.new(date, "cineembajadoresrio") }

  let(:valid_movie) do
    {
      title:     "El amigo inesperado (VOSE)",
      director:  "Fabienne Godet",
      duration:  "102 min.",
      language:  "V.O.S.E.",
      poster:    "https://cinesembajadores.es/wp-content/uploads/2026/05/poster.jpg",
      showtimes: [
        { time: "19:30", url: "https://www.reservaentradas.com/entrada/madrid/cineembajadores/el-amigo-inesperado-vose/36097/" },
        { time: "20:00", url: "https://www.reservaentradas.com/entrada/madrid/cineembajadoresrio/other/123/" }
      ]
    }
  end

  describe "#normalize" do
    it "raises ArgumentError when input is not an array" do
      expect { cabeza.normalize({}) }.to raise_error(ArgumentError, "Input should be an array.")
    end

    it "raises ArgumentError when input array is empty" do
      expect { cabeza.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
    end

    it "strips parenthetical suffix from title and titleizes" do
      expect(cabeza.normalize([ valid_movie ]).first[:title]).to eq("El Amigo Inesperado")
    end

    it "raises InvalidMovieError for blank title" do
      expect { cabeza.normalize([ valid_movie.merge(title: "") ]) }
        .to raise_error(Scraper::InvalidMovieError)
    end

    it "normalizes V.O.S.E. to :vose" do
      expect(cabeza.normalize([ valid_movie ]).first[:language]).to eq(:vose)
    end

    it "normalizes V.E. with 'DOBLADA AL ESPAÑOL' title to :dubbed" do
      result = cabeza.normalize([ valid_movie.merge(language: "V.E.", title: "El Drama (DOBLADA AL ESPAÑOL)") ])
      expect(result.first[:language]).to eq(:dubbed)
    end

    it "normalizes V.E. without 'DOBLADA' marker to :vo" do
      result = cabeza.normalize([ valid_movie.merge(language: "V.E.", title: "El Drama") ])
      expect(result.first[:language]).to eq(:vo)
    end

    it "raises UnknownLanguageError for unrecognized language string" do
      expect { cabeza.normalize([ valid_movie.merge(language: "DUBBING") ]) }
        .to raise_error(Scraper::UnknownLanguageError)
    end

    it "raises UnknownLanguageError for blank language" do
      expect { cabeza.normalize([ valid_movie.merge(language: "") ]) }
        .to raise_error(Scraper::UnknownLanguageError)
    end

    it "logs the movie title when language normalization fails" do
      expect(Scraper.logger).to receive(:error).with(/El amigo inesperado/)
      expect { cabeza.normalize([ valid_movie.merge(language: nil) ]) }
        .to raise_error(Scraper::UnknownLanguageError)
    end

    it "filters showtimes to cabeza venue only" do
      showtimes = cabeza.normalize([ valid_movie ]).first[:showtimes]
      expect(showtimes.size).to eq(1)
      expect(showtimes.first[:date].strftime("%H:%M")).to eq("19:30")
    end

    it "filters showtimes to rio venue only" do
      showtimes = rio.normalize([ valid_movie ]).first[:showtimes]
      expect(showtimes.size).to eq(1)
      expect(showtimes.first[:date].strftime("%H:%M")).to eq("20:00")
    end

    it "skips movies with no showtimes for the venue" do
      rio_only = valid_movie.merge(showtimes: [
        { time: "18:10", url: "https://www.reservaentradas.com/entrada/madrid/cineembajadoresrio/other/1/" }
      ])
      expect(cabeza.normalize([ rio_only ])).to eq([])
    end

    it "normalizes showtimes to Time objects" do
      showtimes = cabeza.normalize([ valid_movie ]).first[:showtimes]
      expect(showtimes.first[:date]).to be_a(Time)
    end

    it "showtimes include correct date" do
      showtimes = cabeza.normalize([ valid_movie ]).first[:showtimes]
      expect(showtimes.first[:date].strftime("%Y-%m-%d")).to eq("2026-05-13")
    end

    it "normalizes duration to integer" do
      expect(cabeza.normalize([ valid_movie ]).first[:duration]).to eq(102)
    end

    it "returns directors as array" do
      expect(cabeza.normalize([ valid_movie ]).first[:directors]).to eq([ "Fabienne Godet" ])
    end

    it "returns nil duration when blank" do
      expect(cabeza.normalize([ valid_movie.merge(duration: "") ]).first[:duration]).to be_nil
    end

    it "returns empty directors array when blank" do
      expect(cabeza.normalize([ valid_movie.merge(director: "") ]).first[:directors]).to eq([])
    end
  end
end
