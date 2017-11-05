Dotenv.load

module ThunderSoundcloud

  USERS_ENDPOINT = "https://api.soundcloud.com/users"
  USER_ENDPOINT="https://api-v2.soundcloud.com/profile/soundcloud:users:?limit=50&offset=0&client_id=#{ENV['SOUNDCLOUD_CLIENT']}"
  # USERS_ENDPOINT = "https://api.soundcloud.com/users/?client_id=886e9e309f4ba95bafe4624a0bcd1251"

  def self.recent?(created_at)
    DateTime.parse(created_at) >= 1.month.ago
  end

  def self.many_followers?(followers_count)
     followers_count >= 20_000
  end

  def self.format_user(user)
    # byebug
    user
  end

  def self.write_to_csv(user)
    country = user['country'] || 'unknown_country'
    city = user['city'].empty? ? 'unknown_city' : user['city']
    
    CSV.open( Rails.root.join('data', 'leads.csv'), 'a' ) do |writer|
      writer << [user['username'], user['permalink_url'], user['followers_count'], user['reposts_count'], country, city, user['id']]
    end
    # ThunderSoundcloud::format_user(user)
  end

  def self.attempt_user(id)
    user = HTTP.get("#{USERS_ENDPOINT}/#{id}?client_id=#{ENV['SOUNDCLOUD_CLIENT']}").parse
    # check if user has more than 20_0000 followers
    return unless user['errors'].nil? && ThunderSoundcloud.many_followers?(user['followers_count'])

    user_tracks = HTTP.get("https://api-v2.soundcloud.com/profile/soundcloud:users:#{id}?limit=50&offset=0&client_id=#{ENV['SOUNDCLOUD_CLIENT']}").parse
    track_reposts = user_tracks['collection'].select{ |track| track['type'] == 'track-repost' }

    # newest tracks are at the top
    # now check if there are any tracks at all from the last 30 days
    # check first track in list, cause it's the newest
    # unless tracks.first
    return unless track_reposts.any? && ThunderSoundcloud::recent?(track_reposts.first['created_at'])

    ThunderSoundcloud::write_to_csv(user)


  end

end
