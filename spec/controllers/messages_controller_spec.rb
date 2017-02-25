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
    FactoryGirl.create(:message, receiver: partner, status: :delivered)
    FactoryGirl.create(:message, receiver: partner, status: :delivered)
    # this one shuold not be shown in index
    FactoryGirl.create(:reply_message, initial_message: FactoryGirl.create(:message, sender: partner, status: :replied), status: :delivered)
    get :index
    expect(response.status).to eq(200)
    expect(response).to render_template(:index)
    expect(assigns(:messages).count).to eq(2)
  end

  it 'should show message' do
    login partner
    message = FactoryGirl.create(:message, receiver: partner, status: :delivered)
    get :show, {id: message.id}
    expect(response.status).to eq(200)
    expect(response).to render_template(:show)
  end

  it 'should not show message of others' do
    login partner
    message = FactoryGirl.create(:message, receiver: FactoryGirl.create(:partner))
    get :show, {id: message.id}
    expect(response.status).to eq(403)
  end

  it 'should make reply' do
    login partner
    message = FactoryGirl.create(:message, receiver: partner, status: :delivered)

    expect { post :reply, {id: message.id, text: 'reply text'} }.to change(Message, :count).by(1)

    expect(message.reload.replied?).to be_truthy
    expect(response.status).to eq(302)
    expect(response).to redirect_to message_path(id: message.id)
  end

  it 'should make anonymous message' do
    expect {
      post :create, {
        sender_name: "anony",
        receiver_id: partner.id,
        receiver_name: partner.name,
        text: "okie dokie"
      }
    }.to change(Message, :count).by(1)

    expect(response.status).to eq(302)
    expect(response).to redirect_to("/#{partner.name}")
  end

end