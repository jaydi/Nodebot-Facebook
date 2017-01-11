FactoryGirl.define do
  factory :user do
    messenger_id "12345"
    name "Will"
  end
  factory :partner_without_profile, class: User do
    email "jaydi727@gmail.com"
    password "lj7723kr"
  end
  factory :partner_without_messenger, class: User, parent: :partner_without_profile do
    profile_pic "image_url"
    name "Will"
    name_url "willey"
  end
  factory :partner, class: User, parent: :partner_without_messenger do
    messenger_id "12345"
    is_partner true
  end
end
