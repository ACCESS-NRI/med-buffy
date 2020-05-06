require_relative "../spec_helper.rb"

describe RemoveReviewerNResponder do

  subject do
    described_class
  end

  describe "listening" do
    before { @responder = subject.new({bot_github_user: 'botsci'}, {}) }

    it "should listen to new comments" do
      expect(@responder.event_action).to eq("issue_comment.created")
    end

    it "should define regex" do
      expect(@responder.event_regex).to match("@botsci remove reviewer 1")
      expect(@responder.event_regex).to match("@botsci remove reviewer 33B")
      expect(@responder.event_regex).to_not match("assign remove @xuanxu as reviewer 2")
      expect(@responder.event_regex).to_not match("@botsci remove reviewer")
    end
  end

  describe "#process_message" do
    before do
      @responder = subject.new({ bot_github_user: 'botsci' }, {})
      disable_github_calls_for(@responder)

      @msg = "@botsci remove reviewer 33"
      @responder.match_data = @responder.event_regex.match(@msg)

      @issue = OpenStruct.new({ body: "...Reviewer list: 33: <!--reviewer-33--> @buffy <!--end-reviewer-33--> ..." })
      allow(@responder).to receive(:issue).and_return(@issue)

      @context = OpenStruct.new({ repo: "buffy/test", issue_id: 1 })
    end

    it "should update the body of the issue" do
      expected_new_body = "...Reviewer list: 33: <!--reviewer-33--> Pending <!--end-reviewer-33--> ..."
      expect(@responder).to receive(:update_issue).with(@context, { body: expected_new_body })
      @responder.process_message("Hello @botsci", @context)
    end

    it "should update the body of the issue with custom text" do
      @responder.params = { no_reviewer_text: 'TBD' }
      expected_new_body = "...Reviewer list: 33: <!--reviewer-33--> TBD <!--end-reviewer-33--> ..."
      expect(@responder).to receive(:update_issue).with(@context, { body: expected_new_body })
      @responder.process_message("Hello @botsci", @context)
    end

    it "should respond to github" do
      expect(@responder).to receive(:respond).with("Reviewer 33 removed!", @context)
      @responder.process_message("Hello @botsci", @context)
    end
  end
end