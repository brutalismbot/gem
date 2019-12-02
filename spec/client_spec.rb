RSpec.describe Brutalismbot::Client do
  subject { Brutalismbot::Client.stub }

  context "#lag_time" do
    it "should return the default lag time" do
      expect(subject.lag_time).to eq 9000
    end
  end

  context "#pull" do
    let(:post) { Brutalismbot::Reddit::Post.stub }

    it "should pull the latest posts" do
      stub_request(:get, "https://www.reddit.com/r/brutalism/new.json").to_return(body: {data: {children: [post]}}.to_json)
      expect(subject.posts).to receive(:max_time).and_return post.created_utc.to_i - 86400
      expect(subject.posts).to receive(:push).once
      subject.pull
    end
  end

  context "#push" do
    let(:post) { Brutalismbot::Reddit::Post.stub }

    it "should push a post to Twitter and Slack" do
      expect(subject.slack).to   receive(:push).with(post, dryrun: nil)
      expect(subject.twitter).to receive(:push).with(post, dryrun: nil)
      subject.push(post)
    end
  end
end
