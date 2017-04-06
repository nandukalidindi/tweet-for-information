class AlchemyWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :crawl

  def perform(snippet_id, analysis_type)
    AlchemyAPI.key = "95832f7a3c1ace795f69b37a83c2b1de3407f897"

    snippet = UserSnippet.find(snippet_id)
    if snippet.present?
      results = AlchemyAPI.search(analysis_type.to_sym, text: "#{snippet.title} #{snippet.content}")
      if results.present?
        results.each do |result|
          unless ['RT'].include?(result['text'])
            keyword = snippet.user_keywords.create(analysis_type: analysis_type.to_sym, keyword: result['text'], relevance: result['relevance'])

            TwitterQueryWorker.perform_async(keyword.id)
            GoogleNewsQueryWorker.perform_async(keyword.id)
            WikiQueryWorker.perform_async(keyword.id)
            YoutubeQueryWorker.perform_async(keyword.id)
            RedditQueryWorker.perform_async(keyword.id)
          end
        end
      end
    end
  end
end
