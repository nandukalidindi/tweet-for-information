require 'net/http'

class BingQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    if user_keyword.present?
      begin
        uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/news/search')
        uri.query = URI.encode_www_form({
            'q' => keyword_id,
            'count' => '10',
            'offset' => '0',
            'mkt' => 'en-us',
            'safeSearch' => 'Moderate'
        })

        request = Net::HTTP::Get.new(uri.request_uri)
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = '{subscription key}'
        # Request body
        request.body = "{body}"

        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end

        response.body
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end
