class WelcomeController < ApplicationController
  def door
    set_door_layout_flag
  end
end