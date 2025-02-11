# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Reports do
  include SwaggerHelper::TestMethods
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @account = create(:account, email: @login, password: @password, profile: { display_name: "Foo", created_at: Time.new(2024, 9, 20, 16, 50, 0) })
    set_oauth_grant_with_token(oauth_grant_with_token(@account))
  end

  describe "post /reports" do
    before do
      @endpoint = "/api/reports"
      @target_profile = create(:profile)
      @conversation = create(:conversation, profile1: @account.profile, profile2: @target_profile)
      @message = create(:message, sender: "profile2", conversation: @conversation)
      @message2 = create(:message, sender: "profile2", conversation: @conversation)
    end

    it "Gets a bad request when not providing a target profile" do
      authorized_post @endpoint

      assert_predicate last_response, :bad_request?
      assert_response_schema_confirm(400)
    end

    it "gets a bad request if the message id does not exist" do
      body = {
        target_profile_id: @target_profile.id,
        type: "spam",
        comment: "They are trying to trick users!!",
        message_ids: [-999]
      }
      assert_difference "Report.count", 0 do
        authorized_post @endpoint, body.to_json

        assert_predicate last_response, :unprocessable?
        assert_schema_conform(422)
      end
    end

    it "Reports a profile" do
      body = {
        target_profile_id: @target_profile.id,
        type: "spam",
        comment: "They are trying to trick users!!"
      }
      assert_difference "Report.count", 1 do
        authorized_post @endpoint, body.to_json

        assert_predicate last_response, :no_content?
      end

      created_report = Report.last

      assert_equal body[:target_profile_id], created_report.target_profile_id
      assert_equal body[:type], created_report.type
      assert_equal body[:comment], created_report.comment
      assert_empty created_report.message_ids
    end

    it "reports a profile and a few messages" do
      body = {
        target_profile_id: @target_profile.id,
        type: "spam",
        comment: "They are trying to trick users!!",
        message_ids: [@message.id, @message2.id]
      }
      assert_difference "Report.count", 1 do
        authorized_post @endpoint, body.to_json

        assert_predicate last_response, :no_content?
      end

      created_report = Report.last

      assert_equal body[:target_profile_id], created_report.target_profile_id
      assert_equal body[:type], created_report.type
      assert_equal body[:comment], created_report.comment
      assert_equal body[:message_ids], created_report.message_ids
    end
  end
end
