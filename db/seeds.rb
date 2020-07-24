# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

Admin.create(email: "wojtek@grabski.ca", password: "testtest", password_confirmation: "testtest") if Admin.count.zero?

User.create(email: "wojtek@grabski.ca", password: "testtest", password_confirmation: "testtest") if User.count.zero?

if Salesperson.count.zero?
  Salesperson.create(email: "sales1@test.ca", password: "testtest", password_confirmation: "testtest")
  Salesperson.create(email: "sales2@test.ca", password: "testtest", password_confirmation: "testtest")
end

require Rails.root.join("db/seeds/marketing_emails.rb")

# Product.create( name: 'Large Sleeve Design', size: 'l', type: 'design', slug: '' )

# Product.create( name: 'Large Design', type: 'design', slug: 'large-design' )
