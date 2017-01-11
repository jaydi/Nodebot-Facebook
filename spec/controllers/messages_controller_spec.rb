require 'rails_helper'

RSpec.describe MessagesController do
  let(:user) { FactoryGirl.create(:user) }
  let(:partner_without_profile) { FactoryGirl.create(:partner_without_profile) }
  let(:partner_without_messenger) { FactoryGirl.create(:partner_without_messenger) }
  let(:partner) { FactoryGirl.create(:partner) }

  it 'should redirect to edit page if info not filled' do
    login partner_without_profile
    get :index
    expect(response.status).to eq(302)
    expect(response).to redirect_to(edit_user_registration_path)
  end

  it 'should redirect to pair page if not paired' do
    login partner_without_messenger
    get :index
    expect(response.status).to eq(302)
    expect(response).to redirect_to(users_pair_path)
  end

  it 'should show index page' do
    login partner
    get :index
    expect(response.status).to eq(200)
    expect(response).to render_template(:index)
  end

  it 'should show message' do
    login partner
    message = FactoryGirl.create(:message, receiver: partner)
    get :show, {id: message.id}
    expect(response.status).to eq(200)
    expect(response).to render_template(:show)
  end

  xit 'should not show message of others' do
    login partner
    message = FactoryGirl.create(:message, receiver: FactoryGirl.create(:partner))
    get :show, {id: message.id}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(messages_path)
  end

end