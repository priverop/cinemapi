# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/client'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/malda/calendar_parser'
require_relative '../../../../lib/scraper/malda/post_finder'
require_relative '../../../../lib/scraper/malda/movie_parser'
require_relative '../../../../lib/scraper/malda/normalizer'
require_relative '../../../../lib/scraper/base_orchestrator'
require_relative '../../../../lib/scraper/malda/orchestrator'

RSpec.describe Scraper::Malda::Orchestrator do
  let(:theater)         { double("Theater", website: "https://www.cinemamalda.com/cartelera-dia-dia/") }
  let(:calendar_parser) { instance_double(Scraper::Malda::CalendarParser) }
  let(:post_finder)     { instance_double(Scraper::Malda::PostFinder) }
  let(:movie_parser)    { instance_double(Scraper::Malda::MovieParser) }
  let(:normalizer)      { instance_double(Scraper::Malda::Normalizer) }
  let(:importer)        { instance_double(Scraper::Importer, import: nil) }

  let(:movies) do
    [
      { title: "RESURRECTION", language: "VOSE", showtimes: [ Time.utc(2026, 5, 26, 17, 5) ] },
      { title: "SORDA", language: "VOE", showtimes: [ Time.utc(2026, 5, 28, 20, 0) ] }
    ]
  end

  before do
    allow(Scraper::Client).to receive(:read).and_return("<html></html>")
    allow(Scraper::Malda::CalendarParser).to receive(:new).and_return(calendar_parser)
    allow(calendar_parser).to receive(:movies).and_return(movies)
    allow(Scraper::Malda::PostFinder).to receive(:new).and_return(post_finder)
    allow(post_finder).to receive(:url).and_return(URI("https://www.cinemamalda.com/x/"))
    allow(Scraper::Malda::MovieParser).to receive(:new).and_return(movie_parser)
    allow(movie_parser).to receive(:parse).and_return({ title: "X" })
    allow(Scraper::Malda::Normalizer).to receive(:new).and_return(normalizer)
    allow(normalizer).to receive(:normalize).and_return([])
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all movies resolve a detail page" do
      it "imports data for each movie" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(2).times
      end

      it "fetches the cartelera page and each detail page" do
        described_class.run(theater)
        expect(Scraper::Client).to have_received(:read).exactly(3).times
      end
    end

    context "when a movie has no matching post" do
      before { allow(post_finder).to receive(:url).and_return(nil) }

      it "still imports it without fetching a detail page" do
        described_class.run(theater)
        expect(movie_parser).not_to have_received(:parse)
        expect(importer).to have_received(:import).exactly(2).times
      end
    end

    context "when one movie fails" do
      before do
        calls = 0
        allow(Scraper::Malda::Normalizer).to receive(:new) do
          calls += 1
          raise StandardError, "boom." if calls == 1

          normalizer
        end
      end

      it "continues and imports the remaining movies" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(1).times
      end
    end
  end
end
