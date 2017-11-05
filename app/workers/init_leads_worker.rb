require 'soundcloud'
Dotenv.load

class InitLeadsWorker
  include Sidekiq::Worker

  def perform(*args)
    # for now we hard code artists to seed, with their soundcloud handles
    client = Soundcloud.new(client_id: ENV['SOUNDCLOUD_CLIENT'])
    seed_handles = ['eugenecam']

    seed_handles.each do |handle|
      user_id = client.get('/users', q: handle).first['id']
      ScrapeFollowingWorker.perform_async(user_id, 1)
    end
  end
end
