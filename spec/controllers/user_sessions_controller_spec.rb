require 'rails_helper'

RSpec.describe UserSessionsController do
  let(:celeb) { FactoryGirl.create(:celeb_without_info) }
  let(:info_filled_celeb) { FactoryGirl.create(:celeb_without_pairing) }
  let(:paired_celeb) { FactoryGirl.create(:celeb) }

  it 'should show sign in page' do
    get :new
    expect(response.status).to eq(200)
    expect(response).to render_template(:new)
  end

  it 'should not let sign in if false email' do
    post :create, { email: 'false email' }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'should not let sign in if false password' do
    post :create, { email: celeb.email, password: 'false password' }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(new_user_session_path)
  end

  it 'should redirect to edit page if info not filled' do
    post :create, { email: celeb.email, password: celeb.password }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_edit_path)
  end

  it 'should redirect to pair page if not paired' do
    post :create, { email: info_filled_celeb.email, password: info_filled_celeb.password }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_pair_path)
  end

  it 'should redirect to messages page if normal' do
    post :create, { email: paired_celeb.email, password: paired_celeb.password }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(messages_path)
  end

  it 'should show new password page' do
    get :request_new_password
    expect(response.status).to eq(200)
    expect(response).to render_template(:request_new_password)
  end

  it 'should not send email if false email' do
    post :send_new_password, { email: 'false email' }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(user_sessions_request_new_password_path)
  end

  it 'should show new passowrd email guide page' do
    post :send_new_password, { email: celeb.email }
    expect(response.status).to eq(200)
    expect(response).to render_template(:new_password_sent)
  end

end