FactoryGirl.define do
  factory :message do
    sender { FactoryGirl.create(:user) }
    receiver { FactoryGirl.create(:celeb_user) }
    text 'message text'
  end
end
