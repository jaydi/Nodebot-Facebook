set :environment, ENV['RAILS_ENV']

every 1.day, :at => '06:00 pm' do
  rake "messages:notice"
end