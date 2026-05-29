class ScrapeFailure < ApplicationRecord
  belongs_to :scrape_run

  validates :error_message, presence: true
end
