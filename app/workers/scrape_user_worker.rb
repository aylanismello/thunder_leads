class ScrapeUserWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(*args)
    ThunderSoundcloudManyReposts::attempt_user(args.first)
  end

end
