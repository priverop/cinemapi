# frozen_string_literal: true

module Scraper
  class BaseOrchestrator
    class << self
      def run(theater)
        scrape_run = Scraper.current_scrape_run

        Scraper.logger.info("Starting scrape for #{theater.website}.")

        calendar_days(theater).each do |day|
          Scraper.logger.tagged(day_label(day)) do
            begin
              process_day(theater, day)
              scrape_run&.increment!(:items_ok)
            rescue => e
              scrape_run&.increment!(:items_failed)
              scrape_run&.record_failure(context: day_label(day).to_s, error_message: "#{e.class}: #{e.message}")
              Scraper.logger.error("Day #{day_label(day)} failed: #{e.class}: #{e.message}.")
            end
          end
        end

        Scraper.logger.info("Done. items_ok=#{scrape_run&.items_ok} items_failed=#{scrape_run&.items_failed}.")
      end

      private

      def calendar_days(_theater)
        raise NotImplementedError, "#{name} must implement .calendar_days."
      end

      def process_day(_theater, _day)
        raise NotImplementedError, "#{name} must implement .process_day."
      end

      def day_label(_day)
        raise NotImplementedError, "#{name} must implement .day_label."
      end
    end
  end
end
