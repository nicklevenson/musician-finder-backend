# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

500.times do 
  user1 = User.create(username: "hello2", email: "hello.com2", location: "poland", photo: "", lat: 51.9189, lng: 19.1344)
  user2 = User.create(username: "hello3", email: "hello.com3", location: "Seattle", photo: "", lat: 47.608013, lng: -122.335167)
end


