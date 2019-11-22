require "brutalismbot/posts/client"
require "brutalismbot/reddit/client"
require "brutalismbot/slack/client"
require "brutalismbot/twitter/client"

module Brutalismbot
  class Client
    attr_reader :posts, :reddit, :slack, :twitter

    def initialize(posts:nil, reddit:nil, slack:nil, twitter:nil)
      @posts   = posts   ||   Posts::Client.new
      @reddit  = reddit  ||  Reddit::Client.new
      @slack   = slack   ||   Slack::Client.new
      @twitter = twitter || Twitter::Client.new
    end

    def lag_time
      lag = ENV["BRUTALISMBOT_LAG_TIME"].to_s
      lag.empty? ? 7200 : lag.to_i
    end

    def pull(min_time:nil, max_time:nil, dryrun:nil)
      # Get time window for new posts
      min_time ||= @posts.max_time
      max_time ||= Time.now.utc.to_i - lag_time

      # Get posts
      posts = @reddit.list(:new)
      posts = posts.select{|post| post.created_between?(min_time, max_time) }
      posts = posts.sort{|a,b| a.created_utc <=> b.created_utc }

      # Persist posts
      posts.map{|post| @posts.push(post, dryrun: dryrun) }

      nil
    end

    def push(post, dryrun:nil)
      # Push to Twitter
      @twitter.push(post, dryrun: dryrun)

      # Push to Slack
      @slack.list.each{|auth| auth.push(post, dryrun: dryrun) }

      nil
    end
  end
end
