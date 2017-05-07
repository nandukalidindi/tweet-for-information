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
    uri = URI('https://api.cognitive.microsoft.com/bing/v5.0/news/')
    uri.query = URI.encode_www_form({
      'q' => user_keyword['keyword'],
      'count' => '10',
      'offset' => '0',
      'mkt' => 'en-us',
      'safeSearch' => 'Moderate'
    })

    request = Net::HTTP::Get.new(uri.request_uri)
    request['Ocp-Apim-Subscription-Key'] = 'ca025a83d82440748fad7f5b68856278'
    request.body = "{body}"

    response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
        http.request(request)
    end

    response = JSON.parse(response.body)

    len = response['value'].length

    response['value'].each_with_index do |news, index|
      message_json = {
        user_keyword_id: user_keyword['id'],
        provider: 'bing',
        uri: news['url'],
        content: news['description'],
        score: ((len-index).to_f/len.to_f) * user_keyword['relevance']
      }

      resp = c.publish({
        topic_arn: "<BING ARN>",
        message: JSON.generate(message_json),
        subject: "Bing",
        message_structure: "raw"
      })
    end
  rescue Exception => e
    p "EXCEPTION encountered: #{e.message} - #{e.backtrace}"
  end
end
