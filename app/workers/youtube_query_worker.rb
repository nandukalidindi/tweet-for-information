# require 'google/api_client'

class YoutubeQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    if user_keyword.present?
      client, youtube = get_service
      begin
        # Call the search.list method to retrieve results matching the specified
        # query term.
        search_response = client.execute!(
          :api_method => youtube.search.list,
          :parameters => {
            :part => 'snippet',
            :q => user_keyword.keyword,
            :maxResults => 25
          }
        )

        results = []

        # Add each result to the appropriate list, and then display the lists of
        # matching videos, channels, and playlists.
        len = search_response.data.items.length
        search_response.data.items.each_with_index do |search_result, index|
          case search_result.id.kind
          when 'youtube#video'
            user_keyword.user_keyword_hits.create(provider: 'youtube', uri: "https://www.youtube.com/watch?v=#{search_result.id.videoId}", content: search_result.snippet.title, score: (((len-index).to_f/len.to_f) * user_keyword.relevance * 0.9))
          end
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end

  def get_service
   client = Google::APIClient.new(
     :key => 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI',
     :authorization => nil,
     :application_name => "WhatsNew",
     :application_version => '1.0.0'
   )
   youtube = client.discovered_api('youtube', 'v3')

   return client, youtube
  end
end
