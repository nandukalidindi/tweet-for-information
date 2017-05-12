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
    results = HTTParty.get("http://en.wikipedia.org/w/api.php?action=opensearch&search=#{CGI::escape(user_keyword['keyword'])}")
    len = results[1].length

    results[1].first(3).each_with_index do |word, index|
      message_json = {
        user_keyword_id: user_keyword['id'],
        provider: 'wiki',
        uri: results[3][index],
        content: results[2][index],
        score: ((len-index).to_f/len.to_f) * user_keyword['relevance']
      }
      p "SENDING MESSAGE TO SNS => #{message_json}"
      resp = c.publish({
        topic_arn: "<WIKI ARN>",
        message: JSON.generate(message_json),
        subject: "Wiki",
        message_structure: "raw"
      })

    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end
