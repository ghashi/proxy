# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name "MyString"
    remaining_data 1000
    ip "MyString"
    next_hop "MyString"
    session_key "12345"
    nonce 1
    timestamp "2014-10-05 21:58:26"
  end
end
