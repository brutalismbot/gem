require "forwardable"
require "json"
require "net/http"

require "brutalismbot/logger"
require "brutalismbot/base"

module Brutalismbot
  module Slack
    class Auth < Base
      def channel_id
        @item.dig("incoming_webhook", "channel_id")
      end

      def inspect
        "#<#{self.class} #{team_id}/#{channel_id}>"
      end

      def path
        File.join("team=#{team_id}", "channel=#{channel_id}", "oauth.json")
      end

      def team_id
        @item["team_id"] || @item.dig("team", "id")
      end

      def team_name
        @item["team_name"] || @item.dig("team", "name")
      end

      def to_s3(bucket:nil, prefix:nil)
        bucket ||= ENV["SLACK_S3_BUCKET"] || "brutalismbot"
        prefix ||= ENV["SLACK_S3_PREFIX"] || "data/v1/auths/"
        {
          bucket: bucket,
          key: File.join(*[prefix, path].compact),
          body: to_json,
        }
      end

      def webhook_url
        @item.dig("incoming_webhook", "url")
      end
    end
  end
end
