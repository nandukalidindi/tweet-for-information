require "HTTParty"
require "pry"
require "kafka"
# require "aws-sdk"
require "json"

kafka = Kafka.new(seed_brokers: ["localhost:9092"])

# Aws.config.update({region: 'us-west-2',credentials:
# Aws::Credentials.new('<aws_access_key_id>', '<aws_secret_access_key>')})

# c = Aws::SNS::Client.new(region: 'us-west-2')

kafka.each_message(topic: "keywords") do |message|
  begin
    binding.pry
    user_keyword = JSON.parse(message.value)
    len = Google::Search::News.new(api_key: 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI', query: user_keyword.keyword).count
    if len > 0
      Google::Search::News.new(api_key: 'AIzaSyAXjuT7pgttZ5jPehwRxHysR6BX45-ZrCI', query: user_keyword['keyword']).each_with_index do |news, index|
        user_keyword.user_keyword_hits.create(provider: 'google_news', uri: news.uri, content: news.content, score: (((len-index).to_f/len.to_f) * user_keyword.relevance))

        message_json = {
          user_keyword_id: user_keyword['id'],
          provider: 'google_news',
          uri: news.uri,
          content: news.content,
          score: (((len-index).to_f/len.to_f) * user_keyword['relevance'])
        }

        resp = c.publish({
          topic_arn: "<GOOGLE NEWS ARN>",
          message: JSON.generate(message_json),
          subject: "GOOGLE NEWS",
          message_structure: "raw"
        })
      end
    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end
