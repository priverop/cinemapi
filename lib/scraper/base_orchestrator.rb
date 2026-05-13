# frozen_string_literal: true

module Scraper
  class BaseOrchestrator
    class << self
      def run(theater)
        days_ok     = 0
        days_failed = 0

        Scraper.logger.info("Starting scrape for #{theater.website}.")

        calendar_days(theater).each do |day|
          Scraper.logger.tagged(day_label(day)) do
            begin
              process_day(theater, day)
              days_ok += 1
            rescue => e
              days_failed += 1
              Scraper.logger.error("Day #{day_label(day)} failed: #{e.class}: #{e.message}.")
            end
          end
        end

        Scraper.logger.info("Done. days_ok=#{days_ok} days_failed=#{days_failed}.")
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
