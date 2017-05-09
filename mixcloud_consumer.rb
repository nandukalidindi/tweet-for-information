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
    user_keyword = JSON.parse(message.value)
    results = HTTParty.get("https://api.mixcloud.com/search/?q=#{CGI::escape(user_keyword['keyword'])}&type=tag")

    len = JSON.parse(results.parsed_response)['data'].length

    JSON.parse(results.parsed_response)['data'].each_with_index do |result, index|
      message_json = {
        user_keyword_id: user_keyword['id'],
        provider: 'mixcloud',
        uri: result['url'],
        content: "#{result['name']} => #{result['key']}",
        score: (((len-index).to_f/len.to_f) * user_keyword['relevance'] * 0.85)
      }

      resp = c.publish({
        topic_arn: "<MIXCLOUD ARN>",
        message: JSON.generate(message_json),
        subject: "Mixcloud",
        message_structure: "raw"
      })
    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end
