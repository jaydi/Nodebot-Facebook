workers 1
threads 1, 6
daemonize true

app_dir = File.expand_path("../..", __FILE__)
shared_dir = "#{app_dir}/shared"

# Default to development
rails_env = ENV['RAILS_ENV'] || "staging"
environment rails_env

# Set up socket location
bind "unix://#{shared_dir}/sockets/puma.sock"

# Logging
stdout_redirect "#{shared_dir}/log/puma.stdout.log", "#{shared_dir}/log/puma.stderr.log", true

# Set master PID and state locations
pidfile "#{shared_dir}/pids/puma.pid"
state_path "#{shared_dir}/pids/puma.state"
activate_control_app

lowlevel_error_handler do |ex, env|
  Raven.capture_exception(
    ex,
    :message => ex.message,
    :extra => { :puma => env },
    :culprit => "Puma"
  )
  # note the below is just a Rack response
  [500, {}, ["An error has occurred, and engineers have been informed. Please reload the page. If you continue to have problems, contact admin@kiki.video\n"]]
end

on_worker_boot do
  require "active_record"
  ActiveRecord::Base.connection.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection(YAML.load_file("#{app_dir}/config/database.yml")[rails_env])
end