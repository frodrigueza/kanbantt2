# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)


u1 = User.create!(email: 'felipe@gmail.com', password: '12345678',  name: 'Felipe', last_name: 'Rodriguez', super_admin: true)
u2 = User.create!(email: 'ricardo@gmail.com', password: '12345678',  name: 'Ricardo', last_name: 'Ibanez', super_admin: true)

u1.owned_projects << Project.create(name: 'Kanbantt')
u2.projects << Projects.last

