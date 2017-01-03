Raven.configure do |config|
  config.dsn = 'https://aa23d2cb2e3e462d997fc4374957416f:7151a1e03d084a46b11ada13b2cfd3ec@sentry.io/126065'
  config.environments = ['staging', 'production']
  config.excluded_exceptions = Raven::Configuration::IGNORE_DEFAULT - ["ActiveRecord::RecordNotFound"]
end