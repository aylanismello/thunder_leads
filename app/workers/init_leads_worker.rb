class InitLeadsWorker
  include Sidekiq::Worker

  def perform(*args)
    puts "sup"
    ThunderSoundcloud::get_user_bunch
  end
end
