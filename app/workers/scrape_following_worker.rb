Dotenv.load
class ScrapeFollowingWorker
  include Sidekiq::Worker


  def perform(*args)
    user_id, levels_deep = args
    ThunderCrawler::init(user_id, levels_deep)
  end

end
