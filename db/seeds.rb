# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
User.create!(username:  "Example_User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

User.create!(username:  "testing",
             email: "sneavel@gmail.com",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: false,
             activated: true,
             activated_at: Time.zone.now,
             active: true)

99.times do |n|
  name  = Faker::Name.name.tr(".","")[0..19].downcase.tr(" ", "_").tr("'", "_")  
  email = Faker::Internet.email
  password = "password"
  User.create!(username:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
              
end

users = User.order(:created_at).take(6)

50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| 
    activity = user.activities.create!(content: content, action_id: rand(13)+1, finished_at: 5.minutes.from_now) 
    activity.create_rating
  }
end

Action.create!(content: "sailing")
Action.create!(content: "training")
Action.create!(content: "starcraft")
Action.create!(content: "teaching")
Action.create!(content: "cooking")
Action.create!(content: "greeting")
Action.create!(content: "walking")
Action.create!(content: "gaming")
Action.create!(content: "yelling")
Action.create!(content: "entrenching")
Action.create!(content: "running")
Action.create!(content: "flipping_tables")
Action.create!(content: "sitting")

#tracking relationships
users = User.all
user  = users.first
tracking = users[2..50]
trackers = users[3..40]
tracking.each { |tracked| user.track(tracked) }
trackers.each { |tracker| tracker.track(user) }


#let's get some active activities rolling yo

content = [
  "Just going on a boat for a bit. #sailing",
  "I gotta train #training",
  "#sailing",
  "#sailing",
  "#sailing",
  "Back to work #training",
  "Ready for action #training",
  "Terran it up. #starcraft",
  "Just #teaching some fools",
  "Learning #cooking",
  "Gotta be lazy sometimes. #gaming",
  "#training yo",
  "Out on the river....#sailing",
  "#gaming like the lee young ho himself",
  "tell these kids to learn... #teaching",
  "#greeting people is easy. Remembering their names is hard.",
  "#teaching",
  "back to streaming #starcraft hype"
]

action_ids = [
  1,2,1,1,1,2,2,3,4,5,8,2,1,8,4,6,4,3,1,8
]

for i in 0..15
  u = users[i*2+1]
  activity = u.activities.create!(content: content[i],action_id: action_ids[i])
  activity.create_rating
  u.active = true;
  u.active_id = Activity.first.id
  u.save!
end