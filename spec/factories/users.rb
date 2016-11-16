FactoryGirl.define do
  factory :user do
    sender_id "12345"
    name "Will"
    status User.statuses[:waiting]
  end
  factory :celeb_user, class: User, parent: :user do
    celeb { FactoryGirl.create(:info_filled_celeb) }
  end
end
