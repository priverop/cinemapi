# frozen_string_literal: true

require_relative "base_embajadores_orchestrator"

module Scraper
  module Embajadores
    class RioOrchestrator < BaseEmbajadoresOrchestrator
      class << self
        private

        def venue_slug = "cineembajadoresrio"
      end
    end
  end
end
