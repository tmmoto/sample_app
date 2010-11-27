Factory.define :user do |user| #:user is a class here
  user.name                   "Tibor"
  user.email                  "t6@2example.com"
  user.password               "foobar"
  user.password_confirmation  "foobar"
end
