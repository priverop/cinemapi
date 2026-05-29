# frozen_string_literal: true

require_relative '../../../../lib/scraper/malda/normalizer'
require_relative '../../../../lib/scraper'
require 'spec_helper'

RSpec.describe Scraper::Malda::Normalizer do
  let(:base_url) { URI("https://www.cinemamalda.com/cartelera-dia-dia/") }
  let(:normalizer) { described_class.new(base_url: base_url) }

  let(:input) do
    [ {
      title: "Resurrection",
      directors: "Bi Gan",
      duration: "160 min",
      language: "VOSE",
      description: "En un mundo...",
      poster: "https://www.cinemamalda.com/wp-content/uploads/2026/04/resurrection.jpg",
      genres: [ "Drama", "distopía" ],
      showtimes: [ Time.utc(2026, 5, 26, 17, 5) ]
    } ]
  end

  describe "#normalize" do
    it "returns a normalized movie" do
      expect(normalizer.normalize(input)).to match([ {
        title: "Resurrection",
        directors: [ "Bi Gan" ],
        duration: 160,
        language: :vose,
        description: "En un mundo...",
        poster: "https://www.cinemamalda.com/wp-content/uploads/2026/04/resurrection.jpg",
        genres: [ "Drama", "distopía" ],
        showtimes: [ { date: Time.utc(2026, 5, 26, 17, 5) } ]
      } ])
    end

    it "maps VOE to :vo" do
      expect(normalizer.normalize([ input.first.merge(language: "VOE") ]).first[:language]).to eq(:vo)
    end

    it "maps VOSE to :vose" do
      expect(normalizer.normalize([ input.first.merge(language: "VOSE") ]).first[:language]).to eq(:vose)
    end

    it "raises on unknown language" do
      expect { normalizer.normalize([ input.first.merge(language: "dubbed") ]) }
        .to raise_error(Scraper::UnknownLanguageError)
    end

    it "raises on blank language" do
      expect { normalizer.normalize([ input.first.merge(language: nil) ]) }
        .to raise_error(Scraper::UnknownLanguageError)
    end

    it "tolerates missing metadata (degraded movie)" do
      degraded = { title: "SOLO TITULO", language: "VOE", showtimes: [ Time.utc(2026, 5, 26, 17, 5) ] }
      result = normalizer.normalize([ degraded ]).first
      expect(result[:directors]).to eq([])
      expect(result[:duration]).to be_nil
      expect(result[:genres]).to eq([])
    end

    it "raises ArgumentError when given an empty array" do
      expect { normalizer.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
    end

    it "raises ArgumentError when not given an array" do
      expect { normalizer.normalize("nope") }.to raise_error(ArgumentError, "Input should be an array.")
    end
  end
end
