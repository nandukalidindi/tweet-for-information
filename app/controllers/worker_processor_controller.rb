class WorkerProcessorController < ApplicationController

  skip_before_filter  :verify_authenticity_token

  def youtube
    Rails.logger.info(request.raw_post)
    youtube_message = JSON.parse(JSON.parse(request.raw_post)["Message"] || "{}")
    insert_message(youtube_message)
  end

  def bing
    Rails.logger.info(request.raw_post)
    bing_message = JSON.parse(JSON.parse(request.raw_post)["Message"] || "{}")
    insert_message(bing_message)
  end

  def wiki
    Rails.logger.info(request.raw_post)
    wiki_message = JSON.parse(JSON.parse(request.raw_post)["Message"] || "{}")
    insert_message(wiki_message)
  end

  def reddit
    Rails.logger.info(request.raw_post)
    reddit_message = JSON.parse(JSON.parse(request.raw_post)["Message"] || "{}")
    insert_message(reddit_message)
  end

  def giphy
    Rails.logger.info(request.raw_post)
    giphy_message = JSON.parse(JSON.parse(request.raw_post)["Message"] || "{}")
    insert_message(giphy_message)
  end

  def insert_message(message)
    if message['user_keyword_id']
      user_keyword = UserKeyword.find(message['user_keyword_id'])
      user_keyword.user_keyword_hits.create(
        provider: message['provider'],
        uri: message['uri'],
        content: message['content'],
        score: message['score']
      )
    end
  end
end
