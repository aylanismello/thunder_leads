Dotenv.load
class ScrapeFollowingWorker
  include Sidekiq::Worker


  def perform(*args)
    user_id, levels_deep, genre = args
    ThunderCrawler::init(user_id, levels_deep, genre)
  end

end
