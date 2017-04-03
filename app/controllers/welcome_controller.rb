class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!

  def door
    set_door_layout_flag
  end

end