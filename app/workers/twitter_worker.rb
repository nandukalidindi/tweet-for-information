class TwitterWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :crawl

  def perform
    User.all.each do |user|
      ::Sidekiq.logger.info "    Crawling user #{user.email}"

      begin
        client = Twitter::REST::Client.new do |config|
          config.consumer_key        = "BgB9gfhMrjtSb3ZAy4Zen6u1b"
          config.consumer_secret     = "4vMkasCv3xhs0mRkfEjVePrCQfqoBpxCpgXcGWGTEcE9xywqNR"
        end

        user_authentication = user.authentications.for_provider('twitter').first if user.present?
        options = {}
        options['since_id'] = user_authentication.last_position if user_authentication.present? && user_authentication.last_position.present?
        tweets = client.user_timeline(user_authentication.params['info']['nickname'], options) if user_authentication.present?

        if tweets.present?
          ::Sidekiq.logger.info "        Ingesting #{tweets.count} Tweets"
          tweets.each do |tweet|
            tweet_title = client.status(tweet.id).text
            ::Sidekiq.logger.info "            Tweet #{tweet.id}: #{tweet_title}"
            snippet = user_authentication.snippets.create(title: tweet_title)

            if snippet.present?
              #AlchemyWorker.perform_async(snippet.id, "relation_extraction")
              #AlchemyWorker.perform_async(snippet.id, "concept_tagging")
              #AlchemyWorker.perform_async(snippet.id, "entity_extraction")
              AlchemyWorker.perform_async(snippet.id, "keyword_extraction")
            end
          end

          # Update Latest Tweet ID scanned
          ::Sidekiq.logger.info "    Setting last position to #{tweets.first.id}"
          user_authentication.update_attribute(:last_position, tweets.first.id)
        end
      rescue Exception => e
        ::Sidekiq.logger.info "#{e.message} - #{e.backtrace}"
      end
    end
  end
end
