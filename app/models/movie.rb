class Movie < ApplicationRecord
  enum :data_source, scraper: 0, manual: 1

  has_many :showtimes, dependent: :destroy
  has_many :theaters, through: :showtimes

  serialize :directors, coder: JSON

  validates :title, :duration, presence: true
  validates :title, uniqueness: true
  validates :poster, url: { allow_blank: true }

  # Get the latests n movies
  def self.latest(n)
    order(created_at: :desc).limit(n)
  end

  def display_name
    title
  end
end
