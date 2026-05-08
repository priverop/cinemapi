# frozen_string_literals: true

puts 'BEGIN SEEDING:'

puts 'Removing old stuff:'
puts '- - - - - - - - - -'
Showtime.destroy_all
Movie.destroy_all
Theater.destroy_all
Session.destroy_all
User.destroy_all

puts 'Creating Theaters'
puts '- - - - - - - - - -'
princesa = Theater.create!(name: 'Cine Princesa', location: 'Plaza de los Cubos, Madrid', price: 8.9, discounted_price: 4.9, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/cines-princesa/cartelera/", scraper_key: 1)
plaza = Theater.create!(name: 'Cine Plaza España', location: 'Calle Martín de los Heros, Madrid', price: 8.9, discounted_price: 4.9, discounted_days: [ 'monday', 'wednesday' ], website: "https://www.cinesrenoir.com/cine/renoir-plaza-de-espana/cartelera/", scraper_key: 1)
pio = Theater.create!(name: 'Cinesa Príncipe Pío', location: 'Centro Comercial Principe Pío, Madrid', price: 11.5, discounted_price: 6.5, discounted_days: [ 'wednesday' ], website: "https://www.cinesa.es/cines/principe-pio/", scraper_key: 2, scraper_external_id: "027")

puts 'Creating Users'
puts '- - - - - - - - - -'
User.create!(email_address: "admin@cinemapi.com", password: "123")

puts 'SUCCESS!'
