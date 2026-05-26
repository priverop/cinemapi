# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/verdi_barcelona/list_parser'
require_relative '../../../../lib/scraper/verdi_barcelona/movie_parser'
require_relative '../../../../lib/scraper/verdi_barcelona/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/verdi_barcelona/orchestrator'

RSpec.describe Scraper::VerdiBarcelona::Orchestrator do
  let(:theater)      { double("Theater", website: "https://barcelona.cines-verdi.com/cartelera") }
  let(:list_parser)  { instance_double(Scraper::VerdiBarcelona::ListParser) }
  let(:movie_parser) { instance_double(Scraper::VerdiBarcelona::MovieParser) }
  let(:normalizer)   { instance_double(Scraper::VerdiBarcelona::Normalizer) }
  let(:importer)     { instance_double(Scraper::Importer, import: nil) }

  let(:movies) do
    [
      { imdbid: "tt21825416", slug: "/el-caso-hubener", poster: "https://img/tt21825416.webp" },
      { imdbid: "tt14614892", slug: "/dragon-ball", poster: "https://img/tt14614892.webp" }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("{}")
    allow(Scraper::VerdiBarcelona::ListParser).to receive(:new).and_return(list_parser)
    allow(list_parser).to receive(:movies).and_return(movies)
    allow(Scraper::VerdiBarcelona::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return({})
    allow(Scraper::VerdiBarcelona::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all movies succeed" do
      it "imports each movie" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end

      it "fetches the cartelera and each movie api endpoint" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(3).times
      end

      it "requests the per-movie api url derived from the theater host" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).with(
          URI("https://barcelona.cines-verdi.com/api/get-event-by-imdbid/tt21825416")
        )
      end

      it "injects the listing poster into the parsed movie before normalizing" do
        allow(movie_parser).to receive(:parse) { { title: "X" } }
        described_class.run(theater)
        expect(normalizer).to have_received(:normalize).with([ a_hash_including(poster: "https://img/tt21825416.webp") ])
      end

      it "tags each movie's log lines with the readable slug" do
        allow(Scraper.logger).to receive(:tagged).and_call_original
        described_class.run(theater)
        expect(Scraper.logger).to have_received(:tagged).with("el-caso-hubener")
        expect(Scraper.logger).to have_received(:tagged).with("dragon-ball")
      end
    end

    context "when one movie fails" do
      before do
        calls = 0
        allow(Scraper::VerdiBarcelona::MovieParser).to receive(:new) do
          calls += 1
          raise StandardError, "parse error." if calls == 1

          movie_parser
        end
      end

      it "continues and imports the remaining movies" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(1).times
      end
    end
  end
end
