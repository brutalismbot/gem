require "brutalismbot/r"
require "brutalismbot/s3"
require "brutalismbot/version"
require "logger"
require "net/https"

module Brutalismbot
  class << self
    @@config = {}
    @@logger = Logger.new File::NULL

    def config
      @@config
    end

    def config=(config)
      @@config = config || {}
    end

    def logger
      config[:logger] || @@logger
    end

    def logger=(logger)
      config[:logger] = logger
    end
  end

  class Error < StandardError
  end

  class Auth < OpenStruct
    class IncomingWebhook < OpenStruct; end

    def incoming_webhook
      IncomingWebhook.new dig("incoming_webhook")
    end

    def post(body:, dryrun:nil)
      uri = URI.parse incoming_webhook.url
      ssl = uri.scheme == "https"
      Net::HTTP.start(uri.host, uri.port, use_ssl: ssl) do |http|
        if dryrun
          Brutalismbot.logger.info "POST DRYRUN #{uri}"
        else
          Brutalismbot.logger.info "POST #{uri}"
          req = Net::HTTP::Post.new uri, "content-type" => "application/json"
          req.body = body
          http.request req
        end
      end
    end
  end

  class Post < OpenStruct
    class Data < OpenStruct
    end

    def created_utc
      Time.at(data.created_utc.to_i).utc
    end

    def created_after(time:)
      data.created_utc.to_i > time.to_i
    end

    def data
      Data.new dig("data")
    end

    def permalink
      data.permalink
    end

    def title
      data.title
    end

    def to_slack
      {
        blocks: [
          {
            type: "image",
            title: {
              type: "plain_text",
              text: "/r/brutalism",
              emoji: true,
            },
            image_url: url,
            alt_text: title,
          },
          {
            type: "context",
            elements: [
              {
                type: "mrkdwn",
                text: "<https://reddit.com#{permalink}|#{title}>",
              },
            ],
          },
        ],
      }
    end

    def url
      images = data.preview.dig "images"
      source = images.map{|x| x["source"] }.compact.max do |a,b|
        a.slice("width", "height").values <=> b.slice("width", "height").values
      end
      CGI.unescapeHTML source.dig("url")
    rescue NoMethodError
      data.media_metadata&.values&.first&.dig("s", "u")
    end
  end
end
