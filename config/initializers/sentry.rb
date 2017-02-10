Raven.configure do |config|
  config.dsn = APP_CONFIG[:sentry_dsn]
  config.environments = ['staging', 'production']
  config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT - ["ActiveRecord::RecordNotFound"]
end