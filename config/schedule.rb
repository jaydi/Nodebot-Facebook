set :environment, ENV['RAILS_ENV']

every 1.day, :at => '00:05 am' do
  rake "messages:waste"
end