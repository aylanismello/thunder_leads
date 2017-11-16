require 'soundcloud'
Dotenv.load

class InitLeadsWorker
  include Sidekiq::Worker

  def perform(*args)
    # for now we hard code artists to seed, with their soundcloud handles
    client = Soundcloud.new(client_id: ENV['SOUNDCLOUD_CLIENT'])
    genres = {
      # 'Future Funk': 'yungestbae',
      'Bay Area': 'mozzymusic',
      # 'Baile Funk': 'rennan-mei-litre',
      # 'Future Baile': 'sangobeats',
      # 'House': 'amtrac',
      # 'Galactic Sounds': 'eugene_cam',
      # 'Foreign Sounds': 'steeve-fbkmr',
      # 'Club': 'itscarvell'
    }

    # seed_handles = ['eugenecam']

    genres.each do |genre, handle|
      user_id = client.get('/users', q: handle).first['id']
      binding.pry
      ScrapeFollowingWorker.perform_async(user_id, 1, genre)
    end
  end
end
