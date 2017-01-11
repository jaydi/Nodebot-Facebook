require 'rails_helper'

RSpec.describe UsersController do

  it 'should show edit page' do
    login
    get :edit
    expect(response.status).to eq(200)
    expect(response).to render_template(:edit)
  end

  it 'should update user' do
    login
    name = "new_name"
    profile = "new_picture"
    put :update, {user: {name: name, profile: profile}}
    expect(response.status).to eq(302)
    expect(response).to redirect_to(messages_path)
    expect(subject.current_user.name).to eq(name)
    expect(subject.current_user.profile_pic).to eq(profile)
  end

  it 'should show pair page' do
    login
    get :pair
    expect(response.status).to eq(200)
    expect(response).to render_template(:pair)
  end

end