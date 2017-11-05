class InitLeadsWorkerOld
  include Sidekiq::Worker

  USER_BUNCH_SIZE = 400_000

  def perform(*args)
    puts "sup"
    # whenever we start we need to figure out which id to start on!

    file = CSV.read(Rails.root.join('data', 'leads.csv'))

    # if previous scraping has been done
    if file.last
      starting_idx = (file.last.last.to_i + 1)
    else
      starting_idx = 1
    end

    (starting_idx .. starting_idx + USER_BUNCH_SIZE).each do |id|
      ScrapeUserWorker.perform_async(id)
    end
  end
end
