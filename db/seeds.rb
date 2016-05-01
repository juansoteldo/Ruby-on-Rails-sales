# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = Admin.create( email: 'wojtek@grabski.ca', password: 'testtest', password_confirmation: 'testtest' )
user = User.create( email: 'wojtek@grabski.ca', password: 'testtest', password_confirmation: 'testtest' )
salesperson1 = Salesperson.create( email: 'sales1@test.ca', password: 'testtest', password_confirmation: 'testtest' )
salesperson2 = Salesperson.create( email: 'sales2@test.ca', password: 'testtest', password_confirmation: 'testtest' )

request = user.requests.create(
    has_color: true,
    is_first_time: false,
                     position: 'Hip',
                     notes: 'test note',
                     client_id: '12345'
)
request.save!


# Product.create( name: 'Large Sleeve Design', size: 'l', type: 'design', slug: '' )

# Product.create( name: 'Large Design', type: 'design', slug: 'large-design' )
