# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Food.delete_all

Food.create!([
  {id: 1, name: "Banana", duration_seconds: 432000},
  {id: 2, name: "Orange", duration_seconds: 604800},
  {id: 3, name: "Apple", duration_seconds: 172800},
  {id: 4, name: "Kale", duration_seconds: 604800},
  {id: 5, name: "Spinach", duration_seconds: 604800}
])