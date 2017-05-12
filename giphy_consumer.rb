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
    results = HTTParty.get("http://api.giphy.com/v1/gifs/search?q=#{CGI::escape(user_keyword['keyword'])}&api_key=dc6zaTOxFJmzC")

    len = results.parsed_response['data'].length

    results.parsed_response['data'].first(3).each_with_index do |result, index|
      message_json = {
        user_keyword_id: user_keyword['id'],
        provider: 'giphy',
        uri: result['url'],
        content: result['embed_url'],
        score: (((len-index).to_f/len.to_f) * user_keyword['relevance'] * 0.85)
      }
      p "SENDING MESSAGE TO SNS => #{message_json}"
      resp = c.publish({
        topic_arn: "<GIPHY ARN>",
        message: JSON.generate(message_json),
        subject: "Giphy",
        message_structure: "raw"
      })
    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end
