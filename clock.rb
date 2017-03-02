require 'clockwork'
require './config/boot'
require './config/environment'

module Clockwork  
  every(30.seconds, 'Initiating Crawl...') { TwitterWorker.perform_async }
end
