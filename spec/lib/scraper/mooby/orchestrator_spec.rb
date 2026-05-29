require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/mooby/movie_parser'
require_relative '../../../../lib/scraper/mooby/detail_parser'
require_relative '../../../../lib/scraper/mooby/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/mooby/orchestrator'

RSpec.describe Scraper::Mooby::Orchestrator do
  let(:theater) do
    double("Theater", website: "https://www.moobycinemas.com/cartelera", scraper_external_id: "BAL-BALMES")
  end
  let(:movie_parser)  { instance_double(Scraper::Mooby::MovieParser) }
  let(:detail_parser) { instance_double(Scraper::Mooby::DetailParser, parse: { duration: "140 min." }) }
  let(:normalizer)    { instance_double(Scraper::Mooby::Normalizer) }
  let(:importer)      { instance_double(Scraper::Importer, import: nil) }

  let(:parsed_movies) do
    [
      {
        title: "Michael", imdbid: "tt1", slug: "/michael", poster: nil,
        showtimes: [
          { date: "20260527212000", language: "VOSE" },
          { date: "20260528210000", language: "VOSE" }
        ]
      },
      {
        title: "Corredora", imdbid: "tt2", slug: "/corredora", poster: nil,
        showtimes: [ { date: "20260528193000", language: "CAT" } ]
      }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Mooby::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return(parsed_movies)
    allow(Scraper::Mooby::DetailParser).to receive(:new).and_return(detail_parser)
    allow(Scraper::Mooby::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    it "passes the theater's shop code to the parser" do
      described_class.run(theater)
      expect(Scraper::Mooby::MovieParser).to have_received(:new).with("<html></html>", "BAL-BALMES")
    end

    it "fetches the cartelera once plus one detail page per distinct movie" do
      described_class.run(theater)
      # 1 cartelera + 2 distinct detail pages
      expect(Scraper::Client).to have_received(:read).exactly(3).times
    end

    it "fetches each detail page only once even across days" do
      described_class.run(theater)
      expect(Scraper::Mooby::DetailParser).to have_received(:new).exactly(2).times
    end

    it "imports one batch per distinct date" do
      described_class.run(theater)
      expect(importer).to have_received(:import).exactly(2).times
    end

    context "when a detail page fetch fails" do
      before do
        allow(Scraper::Client).to receive(:read).and_return("<html></html>") # cartelera
        allow(Scraper::Client).to receive(:read).with(URI("https://www.moobycinemas.com/michael"))
          .and_raise(Scraper::HttpError, "boom.")
      end

      it "still imports the other movies' days" do
        expect { described_class.run(theater) }.not_to raise_error
        expect(importer).to have_received(:import).at_least(:once)
      end
    end

    context "when one day fails" do
      before do
        calls = 0
        allow(Scraper::Mooby::Normalizer).to receive(:new) do
          calls += 1
          raise StandardError, "normalize error." if calls == 1

          normalizer
        end
      end

      it "continues with remaining days" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(1).times
      end
    end
  end
end
