require 'rails_helper'

RSpec.describe CelebsController do
  let(:celeb) { FactoryGirl.create(:celeb) }
  let(:active_celeb) { FactoryGirl.create(:info_filled_celeb, status: Celeb.statuses[:active]) }

  it 'should show celeb page by name' do
    get :show_by_name, { name: active_celeb.name }
    expect(response.status).to eq(200)
    expect(response).to render_template(:show_by_name)
  end

  it 'should show signup page' do
    get :new
    expect(response.status).to eq(200)
    expect(response).to render_template(:new)
  end

  it 'should create celeb' do
    post :create, { email: 'email', password: 'pswd' }
    expect(Celeb.count).to eq(1)
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_edit_path)
  end

  it 'should show edit page' do
    get :edit, nil, { celeb_id: celeb.id }
    expect(response.status).to eq(200)
    expect(response).to render_template(:edit)
  end

  it 'should not update celeb on duplicate name' do
    other_celeb = Celeb.create(email: 'email', password: 'password', name: 'name')
    put :update, { name: other_celeb.name, profile_pic: 'picture' }, { celeb_id: celeb.id }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_edit_path)
  end

  it 'should update celeb' do
    put :update, { name: 'Will', profile_pic: 'picture' }, { celeb_id: celeb.id }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_pair_path)
  end

  it 'should show pair page' do
    get :pair, nil, { celeb_id: celeb.id }
    expect(response.status).to eq(200)
    expect(response).to render_template(:pair)
  end

  it 'should show edit password page' do
    get :edit_password, nil, { celeb_id: celeb.id }
    expect(response.status).to eq(200)
    expect(response).to render_template(:edit_password)
  end

  it 'should not update password on false password' do
    put :update_password, { current_password: 'false password', new_password: 'pswd2' }, { celeb_id: celeb.id }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_edit_password_path)
  end

  it 'should update password' do
    new_pswd = 'new_pswd'
    put :update_password, { current_password: celeb.password, new_password: new_pswd }, { celeb_id: celeb.id }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(celebs_edit_path)
    expect(celeb.reload.password).to eq(new_pswd)
  end

  it 'should deactivate celeb' do
    delete :destroy, nil, { celeb_id: active_celeb.id }
    expect(response.status).to eq(302)
    expect(response).to redirect_to(root_path)
    expect(active_celeb.reload.status).to eq('deactivated')
  end

end