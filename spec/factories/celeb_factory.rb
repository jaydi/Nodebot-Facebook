FactoryGirl.define do
  factory :celeb_without_info, class: Celeb do
    email "will@email.com"
    password "12341234"
  end
  factory :celeb_without_pairing, class: Celeb, parent: :celeb_without_info do
    name "Will"
    profile_pic "picture_url"
  end
  factory :celeb, parent: :celeb_without_pairing do
    user { FactoryGirl.create(:user) }
  end
end