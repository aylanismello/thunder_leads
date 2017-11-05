Dotenv.load

module ThunderCrawler
  USERS_ENDPOINT = "https://api.soundcloud.com/users"

  def self.write_to_csv(user)
    # check if this user already exists first

    country = user['country'] || 'unknown_country'
    city = user['city'] || 'unknown_city'

    CSV.open( Rails.root.join('data', 'leads.csv'), 'a' ) do |writer|
      writer << [user['username'], user['permalink_url'], user['followers_count'], user['reposts_count'], country, city, user['id']]
    end
  end

  def self.user_is_new?(user)
    CSV.open( Rails.root.join('data', 'leads.csv'), 'r' ) do |writer|
      writer.readlines.each do |csv_entry|
        if csv_entry.first == user['username']
          puts "#{user['username']} exists already!"
          return false
        end
      end
    end

    true
  end

  def self.init(user_id, levels_deep)
    user = HTTP.get("#{USERS_ENDPOINT}/#{user_id}/followings?client_id=#{ENV['SOUNDCLOUD_CLIENT']}").parse

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
        if ThunderCrawler::user_is_new?(user) && user['followers_count'] >= 5_000
          ThunderCrawler::write_to_csv(user)
        end

        next_href = user['next_href']
      end
    end

  end
end
