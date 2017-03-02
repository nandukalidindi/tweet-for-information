class WikiQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query
  
  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)
    
    if user_keyword.present?
      begin
        results = HTTParty.get("http://en.wikipedia.org/w/api.php?action=opensearch&search=#{CGI::escape(user_keyword.keyword)}")
        len = results[1].length
      
        results[1].each_with_index do |word, index|
          user_keyword.user_keyword_hits.create(provider: 'wiki', uri: results[3][index], content: results[2][index], score: ((len-index).to_f/len.to_f) * user_keyword.relevance)
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end

