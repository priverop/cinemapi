# frozen_string_literal: true

require_relative '../../../../lib/scraper/zumzeig/normalizer'
require_relative '../../../../lib/scraper'

require 'spec_helper'

RSpec.describe Scraper::Zumzeig::Normalizer do
  describe "#normalize" do
    let(:base_url) { URI("https://zumzeigcine.coop/es/calendario/") }
    let(:normalizer) { described_class.new(base_url: base_url) }

    let(:input) do
      [ {
        title: "La chica del coro",
        directors: "Urška Djukić",
        duration: "89'",
        language: "VOSCAT Sá 16.5.26 19:30, el resto VOSE",
        description: "Sinopsis breve",
        poster: "/site/assets/files/13898/la-chica-del-coro-zumzeig1.jpg",
        genres: [ "estrenes" ],
        showtimes: [ Time.utc(2026, 5, 20, 18, 30), Time.utc(2026, 5, 21, 21, 30) ]
      } ]
    end

    it "returns normalized movies" do
      expect(normalizer.normalize(input)).to match([ {
        title: "La Chica Del Coro",
        directors: [ "Urška Djukić" ],
        duration: 89,
        language: :vose,
        description: "Sinopsis breve",
        poster: "https://zumzeigcine.coop/site/assets/files/13898/la-chica-del-coro-zumzeig1.jpg",
        genres: [ "estrenes" ],
        showtimes: [
          { date: Time.utc(2026, 5, 20, 18, 30) },
          { date: Time.utc(2026, 5, 21, 21, 30) }
        ]
      } ])
    end

    it "splits multiple directors by comma" do
      multi = input.first.merge(directors: "Andrés Antebi Arnó, Pablo González Morandi")
      expect(normalizer.normalize([ multi ]).first[:directors]).to eq([ "Andrés Antebi Arnó", "Pablo González Morandi" ])
    end

    it "maps VOSE to :vose" do
      expect(normalizer.normalize([ input.first.merge(language: "VOSE") ]).first[:language]).to eq(:vose)
    end

    it "maps doblada to :dubbed" do
      expect(normalizer.normalize([ input.first.merge(language: "Doblada al castellano") ]).first[:language]).to eq(:dubbed)
    end

    it "raises on unknown language" do
      expect do
        normalizer.normalize([ input.first.merge(language: "Mute") ])
      end.to raise_error(Scraper::UnknownLanguageError)
    end

    it "raises on blank language" do
      expect do
        normalizer.normalize([ input.first.merge(language: nil) ])
      end.to raise_error(Scraper::UnknownLanguageError)
    end

    it "raises ArgumentError when given an empty array" do
      expect { normalizer.normalize([]) }.to raise_error(ArgumentError, "Input array is empty.")
    end

    it "raises ArgumentError when not given an array" do
      expect { normalizer.normalize("nope") }.to raise_error(ArgumentError, "Input should be an array.")
    end
  end
end
