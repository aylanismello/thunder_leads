Dotenv.load

module ThunderCrawler
  USERS_ENDPOINT = "https://api.soundcloud.com/users"
  FOLLOWERS_MIN = 30_000

  def self.write_to_csv(user, genre, levels_deep)
    # check if this user already exists first

    country = user['country'] || 'unknown_country'
    city = user['city'] || 'unknown_city'

    CSV.open( Rails.root.join('data', "#{genre}.csv"), 'a' ) do |writer|
      writer << [user['username'], user['permalink_url'], user['followers_count'], country, city, user['id'], user['reposts_count'], levels_deep ]
    end
  end

  def self.recent?(created_at)
    DateTime.parse(created_at) >= 1.month.ago
  end

  def self.user_is_new?(user, genre)
    CSV.open( Rails.root.join('data', "#{genre}.csv"), 'r' ) do |writer|
      writer.readlines.each do |csv_entry|
        if csv_entry.first == user['username']
          puts "#{user['username']} exists already in the #{genre} genre CSV!"
          return false
        end
      end
    end

    true
  end

  def self.user_matches_criteria(user)
    return false unless user['followers_count'] >= FOLLOWERS_MIN
    user_tracks = HTTP.get("https://api-v2.soundcloud.com/profile/soundcloud:users:#{user['id']}?limit=50&offset=0&client_id=#{ENV['SOUNDCLOUD_CLIENT']}").parse
    return false unless user_tracks['collection']
    track_reposts = user_tracks['collection'].select{ |track| track['type'] == 'track-repost' }

    # this is asking if there has been a repost made in the last month
    return false unless track_reposts.count >= 5 && track_reposts.first(5).all? { |repost| ThunderCrawler::recent?(repost['created_at'])}
    # ThunderCrawler::recent?(track_reposts.first['created_at'])

    true
  end

  def self.init(user_id, levels_deep, genre)
    pretty_genre = genre.downcase.split(' ').join('_')

    unless File.exist?(Rails.root.join('data', "#{pretty_genre}.csv"))
      CSV.open( Rails.root.join('data', "#{pretty_genre}.csv"), 'wb' ) do |writer|
        writer << ['username', 'permalink_url', 'followers_count', 'country', 'city', 'id', 'reposts_count', 'levels_deep']
      end
    end

    user = HTTP.get("#{USERS_ENDPOINT}/#{user_id}/followings?client_id=#{ENV['SOUNDCLOUD_CLIENT']}").parse

    puts "#{levels_deep} crawling with #{user['username']} as base user"

    if user['errors']
      puts "error getting user #{user['username']}"
      return
    end

    followed_users = user['collection']
    return unless followed_users.any?
    next_href = user['next_href']

    while next_href.present?
      followed_users.each do |user|
        # also check if this user exists in csv
        if ThunderCrawler::user_is_new?(user, pretty_genre) && ThunderCrawler::user_matches_criteria(user)
          ThunderCrawler::write_to_csv(user, pretty_genre, levels_deep)
          ScrapeFollowingWorker.perform_async(user['id'], levels_deep + 1, genre)
        end

        next_href = user['next_href']
      end
    end

  end
end
