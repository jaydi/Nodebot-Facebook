config_hash = YAML.load_file("#{Rails.root.to_s}/config/config.yml")[Rails.env]
APP_CONFIG = config_hash.symbolize_keys

require 'waikiki/http_persistent'
require 'waikiki/message_sender'

# Active Job
Rails.application.configure do
  config.active_job.queue_adapter = Rails.env.production? ? :sidekiq : :inline
end