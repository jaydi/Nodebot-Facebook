require 'sinatra/base'
require 'sinatra/json'


class MockServer < Sinatra::Base

  post '/meter/:id/end' do
    json id: params[:id], kind: 'luxury',
         meter: { fare: 45000, base: 8000, toll: 1500, distance: 12000, seconds: 1500 }
  end

end