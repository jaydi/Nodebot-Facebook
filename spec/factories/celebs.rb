FactoryGirl.define do
  factory :celeb do
    email "will@email.com"
    password "12341234"
  end
  factory :info_filled_celeb, class: Celeb, parent: :celeb do
    name "Will"
    profile_pic "picture_url"
  end
end
