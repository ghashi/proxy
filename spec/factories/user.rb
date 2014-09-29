# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name         "John"
    last_access  DateTime.now
    ip          "192.168.19.2"
    next_hop    "192.168.19.2"
  end
end
