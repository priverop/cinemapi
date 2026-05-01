class Showtime < ApplicationRecord
  enum :language, dubbed: 0, vo: 1, vose: 2

  belongs_to :movie
  belongs_to :theater

  validates :showtime, presence: true
end
