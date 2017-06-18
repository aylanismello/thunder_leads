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


  def self.get_user_bunch
    # users = HTTP.get("#{USERS_ENDPOINT}").parse
    (1..1000).each do |id|

      user = "#{USERS_ENDPOINT}/#{id}?client_id=#{ENV['SOUNDCLOUD_CLIENT']}"
      # check if user has more than 20_0000 followers
      next unless ThunderSoundcloud.many_followers?(HTTP.get(user).parse['followers_count'])

      user_tracks = HTTP.get("https://api-v2.soundcloud.com/profile/soundcloud:users:#{id}?limit=50&offset=0&client_id=#{ENV['SOUNDCLOUD_CLIENT']}").parse
      track_reposts = user_tracks['collection'].select{ |track| track['type'] == 'track-repost' }

      next unless track_reposts.any? && ThunderSoundcloud::recent?(track_reposts.first['created_at'])
      byebug
      # newest tracks are at the top
      # now check if there are any tracks at all from the last 30 days
      # check first track in list, cause it's the newest
      # unless tracks.first
      byebug

    end
    # byebug

    # puts HTTP.get("https://api.soundcloud.com/users/?client_id=886e9e309f4ba95bafe4624a0bcd1251&followers_count=20000").parse
  end

end
