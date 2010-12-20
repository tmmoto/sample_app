require 'faker'

namespace :db do  #  rake db:reset, in thi context db is the name space
  desc  "Fill database with sample data"
  task :populate => :environment do 
    Rake::Task['db:reset'].invoke
    User.create!( :name => "Miki Mano",
                  :email => "bhsites1@yahoo.com",
                  :password => "foobar",
                  :password_confirmation => "foobar")
  9999.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "password"
      User.create!( :name => name,
                    :email => email,
                    :password => "password",
                    :password_confirmation => "password") 
    end                          
  end
end  