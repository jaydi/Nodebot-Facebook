source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.4'
# Use sqlite3 as the database for Active Record
gem 'mysql2', '~> 0.3.17'
# Use sqlite3 as the database for Test
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# For queue
gem 'sidekiq'
# For app server
gem 'puma'
# For HTTP requests
gem 'httpclient'
# For state machine
gem 'aasm'
# For null instance handling
gem 'andand'
# For scheduled jobs
gem 'whenever'
# For encryption
gem 'attr_encrypted'
# For image storage
gem 'cloudinary'
# For pagination
gem 'kaminari'
# For error report
gem "sentry-raven"
# For authentication
gem "devise"
# For authorization
gem "rolify"
gem "cancancan"

group :development, :test do
  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  # Test environment
  gem 'rspec-rails', '~> 3.0'
  # Fake time
  gem 'timecop'
end

group :test do
  gem 'sqlite3'
  gem 'shoulda-matchers', '~> 3.1'
  gem 'factory_girl_rails'
  gem 'webmock'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  # Mail Check
  gem 'mailcatcher'
  # For console
  gem 'pry'
  gem 'pry-nav'
  gem 'pry-rails'
end

