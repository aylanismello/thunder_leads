# # https://github.com/mperham/sidekiq/wiki/Using-Redis
rails_env = Rails.env || 'development'
host = (rails_env == 'development') ? 'redis://127.0.0.1:6379/12' : ENV['REDIS_URL']


  Sidekiq.configure_server do |config|
    config.redis = { url: "#{host}" }
  end

  Sidekiq.configure_client do |config|
    config.redis = { url: "#{host}" }
  end
