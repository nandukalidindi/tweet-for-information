require "httparty"
require "kafka"
require "aws-sdk"
require "json"

kafka = Kafka.new(seed_brokers: ["localhost:9092"])

Aws.config.update({region: 'us-west-2',credentials:
Aws::Credentials.new('<aws_access_key_id>', '<aws_secret_access_key>')})

c = Aws::SNS::Client.new(region: 'us-west-2')

kafka.each_message(topic: "keywords") do |message|
  begin
    p "====================================================="
    user_keyword = JSON.parse(message.value)
    p "MESSAGE IS #{user_keyword}"
    results = HTTParty.get("http://www.reddit.com/search.json?q=#{CGI::escape(user_keyword['keyword'])}")

    len = results.parsed_response['data']['children'].length

    results.parsed_response['data']['children'].first(3).each_with_index do |result, index|
      message_json = {
        user_keyword_id: user_keyword['id'],
        provider: 'reddit',
        uri: result['data']['url'],
        content: result['data']['selftext_html'],
        score: (((len-index).to_f/len.to_f) * user_keyword['relevance'] * 0.85)
      }
      p "SENDING MESSAGE TO SNS => #{message_json}"
      resp = c.publish({
        topic_arn: "<REDDIT ARN>",
        message: JSON.generate(message_json),
        subject: "Reddit",
        message_structure: "raw"
      })
    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end
