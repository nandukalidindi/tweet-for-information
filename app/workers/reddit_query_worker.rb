class RedditQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query
  
  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)
    
    if user_keyword.present?
      begin
        results = HTTParty.get("http://www.reddit.com/search.json?q=#{CGI::escape(user_keyword.keyword)}")
      
        len = results.parsed_response['data']['children'].length
      
        results.parsed_response['data']['children'].each_with_index do |result, index|
          user_keyword.user_keyword_hits.create(provider: 'reddit', uri: result['data']['url'], content: result['data']['selftext_html'], score: (((len-index).to_f/len.to_f) * user_keyword.relevance * 0.85))
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end

