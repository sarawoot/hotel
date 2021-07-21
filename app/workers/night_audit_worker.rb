class NightAuditWorker
  include Sidekiq::Worker

  def perform(at_date)
    # Do something
  end
end
# NightAuditWorker.perform_async(at_date)