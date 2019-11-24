require "brutalismbot"
require "brutalismbot/posts/stub"
require "brutalismbot/reddit/stub"
require "brutalismbot/slack/stub"

module Brutalismbot
  class Client
    class << self
      def stub
        new(
          posts: Posts::Client.stub,
          slack: Slack::Client.stub,
        )
      end
    end
  end
end
