class Showtime < ApplicationRecord
  belongs_to :movie
  belongs_to :theater

  validates :showtime, presence: true
end
