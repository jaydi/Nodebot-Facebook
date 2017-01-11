module LoginHelper

  def login(user = FactoryGirl.create(:partner))
    @request.env["devise.mapping"] = Devise.mappings[:user]
    sign_in user
  end

end