require 'Library/Twitter'

class TwitterQueryWorker
  include Sidekiq::Worker
  sidekiq_options retry: false, :queue => :query

  def perform(user_keyword_id)
    user_keyword = UserKeyword.find(user_keyword_id)

    if user_keyword.present?
      begin
        # Instantiate the Choreo, using a previously instantiated TembooSession object, eg:
        session = ::TembooSession.new("whatsnew", "myFirstApp", "0P1XaicKwodZmuq2VbFaWNL5Jgy6m068")
        tweetsChoreo = Twitter::Search::Tweets.new(session)
        tweetsInputs = tweetsChoreo.new_input_set()
        tweetsInputs.set_AccessToken("836117688741150720-mrNEVa2MjAhtxxW1mmEmoY2fQ4tVYRV");
        tweetsInputs.set_AccessTokenSecret("Cm58qJiV1TvyCZoGVDnnEU0MO49NehBBn81B7krf41AzW");
        tweetsInputs.set_ConsumerKey("BgB9gfhMrjtSb3ZAy4Zen6u1b");
        tweetsInputs.set_ConsumerSecret("4vMkasCv3xhs0mRkfEjVePrCQfqoBpxCpgXcGWGTEcE9xywqNR");

        tweetsInputs.set_Query(user_keyword.keyword);

        tweetsString = tweetsChoreo.execute(tweetsInputs)

        tweetsData = JSON.parse(tweetsString.get_Response())["statuses"]

        if tweetsData.present?
          tweetsData.each_with_index do |data, index|
            user_keyword.user_keyword_hits.create(provider: 'twitter', uri: "https://twitter.com/statuses/#{data['id_str']}", content: data['text'], score: (((tweetsData.length-index).to_f/tweetsData.length.to_f) * user_keyword.relevance))
          end
        end
      rescue Exception => e
        ::Sidekiq.logger.info "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
      end
    end
  end
end
