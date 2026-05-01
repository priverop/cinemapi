# frozen_string_literal: true

require 'rails_helper'
require_relative '../../../../lib/scraper'
require_relative '../../../../lib/scraper/importer'
require_relative '../../../../lib/scraper/cinesa/api_client'
require_relative '../../../../lib/scraper/cinesa/calendar_parser'
require_relative '../../../../lib/scraper/cinesa/movie_parser'
require_relative '../../../../lib/scraper/cinesa/normalizer'
require_relative '../../../../lib/scraper/cinesa/orchestrator'

RSpec.describe Scraper::Cinesa::Orchestrator do
  let(:fixtures_path) { File.join(File.expand_path('../../../', __dir__), 'fixtures', 'cinesa') }
  let(:calendar_json) { File.read(File.join(fixtures_path, 'film_screening_dates.json')) }
  let(:movies_json)   { File.read(File.join(fixtures_path, 'pio.json')) }
  let(:theater)       { double("Theater", website: "https://www.cinesa.es/cines/cine-pio-xii/", scraper_external_id: "027") }
  let(:api_client)    { instance_double(Scraper::Cinesa::ApiClient) }
  let(:importer)      { instance_double(Scraper::Importer, import: nil) }

  let(:calendar_url) { "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/film-screening-dates" }
  let(:movies_url)   { "https://vwc.cinesa.es/WSVistaWebClient/ocapi/v1/showtimes/by-business-date" }

  before do
    allow(Scraper::Cinesa::ApiClient).to receive(:new).and_return(api_client)
    allow(api_client).to receive(:data).with(calendar_url).and_return(calendar_json)
    allow(api_client).to receive(:data).with(a_string_including(movies_url)).and_return(movies_json)
    allow(Scraper::Importer).to receive(:new).and_return(importer)
  end

  describe ".run" do
    context "when all days succeed" do
      it "imports data for 7 days (capped from 8 available)" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(7).times
      end
    end

    context "when one day fails during API fetch" do
      before do
        calls = 0
        allow(api_client).to receive(:data).with(a_string_including(movies_url)) do
          calls += 1
          raise StandardError, "network error." if calls == 1
          movies_json
        end
      end

      it "continues processing and imports the remaining 6 days" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(6).times
      end
    end

    context "when calendar has fewer than 7 dates" do
      let(:calendar_json) do
        JSON.generate({
          "filmScreeningDates" => [
            { "businessDate" => "2026-04-27" },
            { "businessDate" => "2026-04-28" },
            { "businessDate" => "2026-04-29" }
          ]
        })
      end

      it "imports only the available days" do
        described_class.run(theater)
        expect(importer).to have_received(:import).exactly(3).times
      end
    end
  end
end
