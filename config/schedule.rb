set :environment, ENV['RAILS_ENV']

every 1.day, :at => '02:00 am' do
  rake "messages:waste"
end