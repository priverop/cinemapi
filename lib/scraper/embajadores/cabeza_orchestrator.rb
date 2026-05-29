# frozen_string_literal: true

require_relative "base_embajadores_orchestrator"

module Scraper
  module Embajadores
    class CabezaOrchestrator < BaseEmbajadoresOrchestrator
      class << self
        private

        def venue_slug = "cineembajadores"
      end
    end
  end
end
