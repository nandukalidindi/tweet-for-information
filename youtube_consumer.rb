require "httparty"
require "kafka"
require "aws-sdk"
require "google/apis/youtube_v3"
require "json"

kafka = Kafka.new(seed_brokers: ["localhost:9092"])

Aws.config.update({region: 'us-west-2',credentials:
Aws::Credentials.new('<aws_access_key_id>', '<aws_secret_access_key>')})

c = Aws::SNS::Client.new(region: 'us-west-2')

kafka.each_message(topic: "keywords") do |message|
  begin
    p "====================================================="
    client = get_service
    user_keyword = JSON.parse(message.value)
    p "MESSAGE IS #{user_keyword}"

    search_response = client.list_searches('snippet', {q: user_keyword['keyword'], max_results: 10 })
    results = []

    len = search_response.items.length
    search_response.items.first(3).each_with_index do |search_result, index|
      case search_result.id.kind
      when 'youtube#video'
        message_json = {
          user_keyword_id: user_keyword['id'],
          provider: 'youtube',
          uri: "https://www.youtube.com/watch?v=#{search_result.id.video_id}",
          content: search_result.snippet.title,
          score: (((len-index).to_f/len.to_f) * user_keyword['relevance'] * 0.9)
        }
        p "SENDING MESSAGE TO SNS => #{message_json}"
        resp = c.publish({
          topic_arn: "<YOUTUBE ARN>",
          message: JSON.generate(message_json),
          subject: "Youtube",
          message_structure: "raw"
        })
      end
    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end

def get_service
 client = Google::Apis::YoutubeV3::YouTubeService.new
 client.key = 'AIzaSyAYHPlUQ39YPZdiROtBy1D7WExx_2lYZMs'

 return client
end
