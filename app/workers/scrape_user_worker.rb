class ScrapeUserWorker
  include Sidekiq::Worker
  sidekiq_options retry: true

  def perform(*args)
    ThunderSoundcloud::attempt_user(args.first)
  end

end
