namespace :sidekiq do
  task get_leads: :environment do
    InitLeadsWorker.new.perform
  end
end
