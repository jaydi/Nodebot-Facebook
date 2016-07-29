class WelcomeController < ApplicationController
  layout 'application_blank'
  skip_before_action :current_celeb

  def door
  end

end