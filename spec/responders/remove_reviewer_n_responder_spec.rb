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

      issue = OpenStruct.new({ body: "...Reviewer list: 33: <!--reviewer-33-->@buffy<!--end-reviewer-33--> ..." })
      allow(@responder).to receive(:issue).and_return(issue)
    end

    it "should remove a reviewer from the body of the issue" do
      expected_new_body = "...Reviewer list: 33: <!--reviewer-33-->Pending<!--end-reviewer-33--> ..."
      expect(@responder).to receive(:update_issue).with({ body: expected_new_body })
      @responder.process_message(@msg)
    end

    it "should update the body of the issue with custom text" do
      @responder.params = { no_reviewer_text: 'TBD' }
      expected_new_body = "...Reviewer list: 33: <!--reviewer-33-->TBD<!--end-reviewer-33--> ..."
      expect(@responder).to receive(:update_issue).with({ body: expected_new_body })
      @responder.process_message(@msg)
    end

    it "should remove the reviewer from assignees" do
      expect(@responder).to receive(:remove_assignee).with("@buffy")
      @responder.process_message(@msg)
    end

    it "should not remove the editor from assignees if not previous editor" do
      expect(@responder).to_not receive(:remove_assignee)

      issue = OpenStruct.new({ body: "...Reviewer 33: <!--reviewer-33--> Pending <!--end-reviewer-33--> ..." })
      allow(@responder).to receive(:issue).and_return(issue)
      @responder.process_message(@msg)

      issue = OpenStruct.new({ body: "...Reviewer 33: <!--reviewer-33-->TBD<!--end-reviewer-33--> ..." })
      allow(@responder).to receive(:issue).and_return(issue)
      @responder.process_message(@msg)
    end

    it "should respond to github" do
      expect(@responder).to receive(:respond).with("Reviewer 33 removed!")
      @responder.process_message(@msg)
    end
  end
end