# frozen_string_literal: true

class ScraperController < DashboardController
  def run
    Scraper.run_all
    redirect_to backoffice_root_path, notice: "Scraper finished."
  rescue => e
    Rails.logger.error("Scraper failed: #{e.class}: #{e.message}.")
    redirect_to backoffice_root_path, alert: "Scraper failed: #{e.message}."
  end
end
