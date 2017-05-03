class BingQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    if user_keyword.present?
      
    end
  end
end
