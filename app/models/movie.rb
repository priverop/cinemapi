class Movie < ApplicationRecord
  has_many :showtimes

  has_many :theaters, through: :showtimes

  validates :name, :duration, :genre, presence: true
end
