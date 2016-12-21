FactoryGirl.define do
  factory :user do
    sender_id "12345"
    name "Will"
    status User.statuses[:waiting]
  end
  factory :celeb_user, class: User, parent: :user do
    celeb { FactoryGirl.create(:celeb_without_pairing) }
  end
end
