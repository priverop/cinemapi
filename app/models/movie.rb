class Movie < ApplicationRecord
  has_many :showtimes, dependent: :destroy

  has_many :theaters, through: :showtimes

  validates :name, :duration, :genre, presence: true

  # Get the latests n movies
  def self.latest(n)
    order(created_at: :desc).limit(n)
  end
end
