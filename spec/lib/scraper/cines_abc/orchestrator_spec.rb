# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/cines_abc/list_parser'
require_relative '../../../../lib/scraper/cines_abc/movie_parser'
require_relative '../../../../lib/scraper/cines_abc/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/cines_abc/orchestrator'

RSpec.describe Scraper::CinesAbc::Orchestrator do
  let(:theater)      { double("Theater", website: "https://elsaler.cinesabc.com/index?pag=cartelera") }
  let(:list_parser)  { instance_double(Scraper::CinesAbc::ListParser) }
  let(:movie_parser) { instance_double(Scraper::CinesAbc::MovieParser) }
  let(:normalizer)   { instance_double(Scraper::CinesAbc::Normalizer) }
  let(:importer)     { instance_double(Scraper::Importer, import: nil) }

  let(:movies) do
    [
      { url: "https://elsaler.cinesabc.com/index?pag=ficha&evento=3074" },
      { url: "https://elsaler.cinesabc.com/index?pag=ficha&evento=3073" }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::CinesAbc::ListParser).to receive(:new).and_return(list_parser)
    allow(list_parser).to receive(:movies).and_return(movies)
    allow(Scraper::CinesAbc::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return({})
    allow(Scraper::CinesAbc::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all movies succeed" do
      it "imports each movie" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end

      it "fetches the cartelera and each ficha page" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(3).times
      end
    end

    context "when one movie fails" do
      before do
        calls = 0
        allow(Scraper::CinesAbc::MovieParser).to receive(:new) do
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
