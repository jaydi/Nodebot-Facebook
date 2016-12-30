require 'rails_helper'

RSpec.describe MessagesController do
  let(:message) { FactoryGirl.create(:message) }

  it 'should not show index without celeb' do
    get :index
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'should not show message of other celeb' do
    # make another celeb and pair
    other_celeb = FactoryGirl.create(:celeb_without_pairing, email: 'other@e.mail')
    FactoryGirl.create(:user, celeb: other_celeb)
    # test with another paired celeb
    get :show, {id: message.id}, {celeb_id: other_celeb.id}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(messages_path)
  end

end