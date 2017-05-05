require 'net/http'

class BingQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    if user_keyword.present?
      begin
        uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/news/')
        uri.query = URI.encode_www_form({
            # Request parameters
            'Category' => 'Politics'
        })

        request = Net::HTTP::Get.new(uri.request_uri)
        # Request headers
        request['Ocp-Apim-Subscription-Key'] = 'ca025a83d82440748fad7f5b68856278'
        # Request body
        request.body = "{body}"

        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
            http.request(request)
        end

        response = JSON.parse(response.body)

        full_news = []

        response['value'].each do |news|
          full_news << {description: news['description'], url: news['url'], name: news['name'], thumbnail: (((news['image'] || {})['thumbnail'] || {}) ['contentUrl'])}
        end

        response['value'].each_with_index do |news, index|
          user_keyword.user_keyword_hits.create(provider: 'bing', uri: news['url'], content: news['description'], score: ((len-index).to_f/len.to_f) * user_keyword.relevance)
        end

      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end
