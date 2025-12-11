class Movie < ApplicationRecord
  has_many :showtimes, dependent: :destroy

  has_many :theaters, through: :showtimes

  validates :name, :duration, :genre, presence: true
end
