class ScrapeRun < ApplicationRecord
  enum :status, running: 0, success: 1, failed: 2

  belongs_to :theater
  has_many :scrape_failures, dependent: :destroy

  scope :recent, -> { order(created_at: :desc) }
  scope :on_date, ->(date) { where(created_at: date.beginning_of_day..date.end_of_day) }

  def self.daily_summaries
    group("DATE(created_at)")
      .select("DATE(created_at) as day, SUM(items_ok) as total_ok, SUM(items_failed) as total_failed")
      .order("day DESC")
  end

  def self.failures_on(date)
    includes(:theater, :scrape_failures).on_date(date).flat_map do |run|
      run.scrape_failures.map do |f|
        {
          scrape_date: f.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          theater: run.theater.name,
          context: f.context,
          error: f.error_message
        }
      end
    end
  end

  def record_failure(context:, error_message:)
    scrape_failures.create!(context: context, error_message: error_message)
  end

  def finalize!
    update!(status: scrape_failures.any? ? :failed : :success)
  end
end
