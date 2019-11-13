# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

band_one = "Rob Marley and the Whalers"
band_two = "Will Whaley and the Comets"
bands = {
  band_one => "Electro-aquatic reggae",
  band_two => "Rock and roll from the ocean floor"
}
bands.each do |name, description|
  Band.find_or_initialize_by(name: name).update!(description: description)
end

comedians = {
  "Jiminy Orcarr": 2,
  "Dilbert Kelp": 5
}
comedians.each do |name, rating|
  Comedian.find_or_initialize_by(name: name).update!(funniness_rating: rating)
end

band1 = Band.find_by(name: band_one)
band2 = Band.find_by(name: band_two)

users_and_reviews = [
  {
    name: "Bob",
    email: "bob@bob.bob",
    reviews: { band1 => "Quite good", band2 => "A bit derivative" }
  },
  {
    name: "Darleen",
    email: "da@rle.en",
    reviews: { band1 => "Out of this world", band2 => "I preferred their earlier stuff" }
  }
]

users_and_reviews.each do |item|
  u = User.find_or_initialize_by(email: item[:email])
  u.update(name: item[:name], password: "Password")#, password_confirmation: "Password")
  u.save!

  item[:reviews].each do |band, review|
    c = Comment.find_or_initialize_by(band: band, user: u)
    c.update(content: review)
    c.save!
  end
end

(1..7).each do |x|
  Performance.create!(start: (DateTime.now + x.days).change({ hour: 19 }))
end
