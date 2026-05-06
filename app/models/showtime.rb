class Showtime < ApplicationRecord
  scope :by_vose, -> { where(language: languages[:vose]) }
  scope :by_date, ->(date) { where(showtime: date.all_day) }
  scope :until_time, ->(time) { where("showtime <= ?", time) }
  scope :from_time, ->(time) { where("showtime >= ?", time) }
  scope :today, -> { where(showtime: Date.current.all_day) }
  enum :language, dubbed: 0, vo: 1, vose: 2

  belongs_to :movie
  belongs_to :theater

  validates :showtime, presence: true
end
