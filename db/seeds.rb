# frozen_string_literals: true

puts 'BEGIN SEEDING:'

puts 'Theaters'
puts '- - - - - - - - - -'
princesa = Theater.create(name: 'Cine Princesa', location: 'Plaza de los Cubos, Madrid', price: 8.9, discounted_price: 4.9, discounted_days: [ 'monday', 'wednesday' ])
plaza = Theater.create(name: 'Cine Plaza España', location: 'Calle Paralela, Madrid', price: 8.9, discounted_price: 4.9, discounted_days: [ 'monday', 'wednesday' ])
pio = Theater.create(name: 'Cinesa Príncipe Pío', location: 'Centro Comercial Principe Pío, Madrid', price: 11.5, discounted_price: 6.5, discounted_days: [ 'wednesday' ])

puts 'Movies'
puts '- - - - - - - - - -'
due = Movie.create(name: 'Due Date', genre: 'comedy', duration: 90)
gone = Movie.create(name: 'Gone Girl', genre: 'thriller', duration: 150)
weapons = Movie.create(name: 'Weapons', genre: 'horror', duration: 110)

puts 'Showtimes'
puts '- - - - - - - - - -'
Showtime.create(theater: princesa, movie: due, showtime: DateTime.parse('2025-12-15 19:00'))
Showtime.create(theater: princesa, movie: due, showtime: DateTime.parse('2025-12-15 22:30'))
Showtime.create(theater: plaza, movie: due, showtime: DateTime.parse('2025-12-15 17:30'))
Showtime.create(theater: pio, movie: due, showtime: DateTime.parse('2025-12-15 23:00'))

Showtime.create(theater: princesa, movie: gone, showtime: DateTime.parse('2025-12-15 20:30'))
Showtime.create(theater: plaza, movie: gone, showtime: DateTime.parse('2025-12-15 19:30'))
Showtime.create(theater: pio, movie: gone, showtime: DateTime.parse('2025-12-15 18:00'))
Showtime.create(theater: pio, movie: gone, showtime: DateTime.parse('2025-12-15 22:00'))

Showtime.create(theater: princesa, movie: weapons, showtime: DateTime.parse('2025-12-15 20:30'))
Showtime.create(theater: princesa, movie: weapons, showtime: DateTime.parse('2025-12-15 23:30'))
Showtime.create(theater: plaza, movie: weapons, showtime: DateTime.parse('2025-12-15 23:30'))
Showtime.create(theater: pio, movie: weapons, showtime: DateTime.parse('2025-12-15 23:30'))

puts 'SUCCESS!'
