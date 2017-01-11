module ControllerMacros
  def login_user(user = FactoryGirl.create(:partner))
    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:user]
      sign_in user
    end
  end

  def match_json(resource)
    include_json(ActiveModelSerializers::SerializableResource.new(resource).as_json)
  end
end
