# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = Admin.create( email: 'wojtek@grabski.ca', password: 'testtest', password_confirmation: 'testtest' )

#request = admin.requests.create(
#                     is_first_time: false,
#                     position: 'hip',
#                    notes: 'test note'
#)
#request.save!


# Product.create( name: 'Large Sleeve Design', size: 'l', type: 'design', slug: '' )

# Product.create( name: 'Large Design', type: 'design', slug: 'large-design' )
