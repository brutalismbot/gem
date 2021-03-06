RSpec.describe Brutalismbot::Client do
  subject { Brutalismbot::Client.stub }

  context "#pull" do
    let(:post) { Brutalismbot::Reddit::Post.stub }

    it "should pull the latest posts" do
      qry = URI.encode_www_form(q: "self:no AND nsfw:no", restrict_sr: true, sort: "new")
      url = "#{subject.reddit.endpoint}/search.json?#{qry}"
      stub_request(:head, post.url).to_return(headers: {"Content-Type" => "image/jpeg"})
      stub_request(:get, url).to_return(body: {data: {children: [post]}}.to_json)
      expect(subject.posts).to receive(:max_time).and_return post.created_utc.to_i - 86400
      expect(subject.posts).to receive(:push).once
      subject.pull min_age: 1800
    end
  end

  context "#push" do
    let(:post) { Brutalismbot::Reddit::Post.stub }
    let(:auth) { Brutalismbot::Slack::Auth.stub }

    it "should push a post to Twitter and Slack" do
      expect(subject.slack).to   receive(:list).and_return [auth]
      expect(subject.slack).to   receive(:push).with(post, auth.webhook_url, dryrun: nil)
      expect(subject.twitter).to receive(:push).with(post, dryrun: nil)
      subject.push(post)
    end
  end
end
