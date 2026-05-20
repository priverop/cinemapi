# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/zumzeig/calendar_parser'
require_relative '../../../../lib/scraper/zumzeig/movie_parser'
require_relative '../../../../lib/scraper/zumzeig/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/zumzeig/orchestrator'

RSpec.describe Scraper::Zumzeig::Orchestrator do
  let(:theater)         { double("Theater", website: "https://zumzeigcine.coop/es/calendario/") }
  let(:calendar_parser) { instance_double(Scraper::Zumzeig::CalendarParser) }
  let(:movie_parser)    { instance_double(Scraper::Zumzeig::MovieParser) }
  let(:normalizer)      { instance_double(Scraper::Zumzeig::Normalizer) }
  let(:importer)        { instance_double(Scraper::Importer, import: nil) }

  let(:movies) do
    [
      { url: "/cinema/films/a/", showtimes: [ Time.utc(2026, 5, 20, 18, 30) ] },
      { url: "/cinema/films/b/", showtimes: [ Time.utc(2026, 5, 21, 21, 30) ] }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Zumzeig::CalendarParser).to receive(:new).and_return(calendar_parser)
    allow(calendar_parser).to receive(:movies).and_return(movies)
    allow(Scraper::Zumzeig::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return({})
    allow(Scraper::Zumzeig::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all movies succeed" do
      it "imports data for each movie" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end

      it "fetches the calendar page and each movie page" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(3).times
      end
    end

    context "when one movie fails" do
      before do
        calls = 0
        allow(Scraper::Zumzeig::MovieParser).to receive(:new) do
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
