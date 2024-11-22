# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Conversations do
  include RackHelper
  before(:all) do
    @login = "foo@retromeet.social"
    @password = "bogus123"
    @schaerbeek = create(:location, latitude: 50.8676041, longitude: 4.3737121, language: "en", name: "Schaerbeek - Schaarbeek, Brussels-Capital, Belgium", country_code: "be", osm_id: 58_260)
    @account1 = create(:account, email: @login, password: @password, profile: { location_id: @schaerbeek.id })
    @account2 = create(:account, profile: { location_id: @schaerbeek.id })
    @conversation = create(:conversation, profile1: @account1.profile, profile2: @account2.profile)
    @message1 = create(:message, conversation: @conversation, sender: "profile1", content: "Message 1")
    @message2 = create(:message, conversation: @conversation, sender: "profile2", content: "Message 2")
    @message3 = create(:message, conversation: @conversation, sender: "profile1", content: "Message 3")
    @message4 = create(:message, conversation: @conversation, sender: "profile1", content: "Message 4")
    @message5 = create(:message, conversation: @conversation, sender: "profile2", content: "Message 5")
  end
  describe "get /conversations/:id/messages" do
    before do
      @endpoint = "/api/conversations/%<id>s/messages"
      @auth = login(login: @login, password: @password)
    end

    it "gets the user information" do
      expected_response = { messages: [
        { id: @message5.id, sender: @account2.profile.id, sent_at: @message5.sent_at.iso8601, content: "Message 5" },
        { id: @message4.id, sender: @account1.profile.id, sent_at: @message4.sent_at.iso8601, content: "Message 4" },
        { id: @message3.id, sender: @account1.profile.id, sent_at: @message3.sent_at.iso8601, content: "Message 3" },
        { id: @message2.id, sender: @account2.profile.id, sent_at: @message2.sent_at.iso8601, content: "Message 2" },
        { id: @message1.id, sender: @account1.profile.id, sent_at: @message1.sent_at.iso8601, content: "Message 1" }
      ] }
      authorized_get @auth, format(@endpoint, id: @conversation.id)

      assert_predicate last_response, :ok?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
  describe "post /conversations/:id/messages" do
    before do
      @endpoint = "/api/conversations/%<id>s/messages"
      @auth = login(login: @login, password: @password)
    end

    it "gets the user information" do
      content = "NEW MESSAGE NOW!"
      expected_response = { sender: @account1.profile.id, content: content }
      body = { content: }
      assert_difference "Message.count", 1 do
        authorized_post @auth, format(@endpoint, id: @conversation.id), body.to_json
      end

      # There's probably better ways to do this, but for now I'm getting the last message and replacing the id and sent_at to avoid issues
      # if it's not the correct message the content and sender will be different
      @message = Message.last
      expected_response[:id] = @message.id
      expected_response[:sent_at] = @message.sent_at.iso8601

      assert_predicate last_response, :created?
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
