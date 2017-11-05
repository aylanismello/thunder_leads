namespace :sidekiq do
  task get_leads: :environment do
    InitLeadsWorker.new.perform
  end

  task get_leads_through_reposts: :environment do
    InitLeadsWorkerOld.new.perform
  end
end
