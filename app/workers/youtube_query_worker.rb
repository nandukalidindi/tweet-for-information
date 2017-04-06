require 'google/apis/youtube_v3'

class YoutubeQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(keyword_id)
    user_keyword = UserKeyword.find(keyword_id)

    if user_keyword.present?
      client = get_service
      begin
        # Call the search.list method to retrieve results matching the specified
        # query term.
        search_response = client.list_searches('snippet', {q: user_keyword.keyword, max_results: 10 })
        results = []

        # Add each result to the appropriate list, and then display the lists of
        # matching videos, channels, and playlists.
        len = search_response.items.length
        search_response.items.each_with_index do |search_result, index|
          case search_result.id.kind
          when 'youtube#video'
            user_keyword.user_keyword_hits.create(provider: 'youtube', uri: "https://www.youtube.com/watch?v=#{search_result.id.video_id}", content: search_result.snippet.title, score: (((len-index).to_f/len.to_f) * user_keyword.relevance * 0.9))
          end
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end

  def get_service
   client = Google::Apis::YoutubeV3::YouTubeService.new
   client.key = 'AIzaSyAYHPlUQ39YPZdiROtBy1D7WExx_2lYZMs'

   return client
  end
end
