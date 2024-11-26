# frozen_string_literal: true

require_relative "../../../test_helper"

describe API::Authenticated::Conversations do
  include SwaggerHelper::TestMethods
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

  describe "get /conversations" do
    before do
      @endpoint = "/api/conversations"
      @auth = login(login: @login, password: @password)
    end
    it "gets all conversations" do
      other_profile = @account2.profile
      expected_response = {
        conversations: [
          {
            id: @conversation.id,
            created_at: @conversation.created_at.iso8601,
            last_seen_at: @conversation.profile1_last_seen_at.iso8601,
            other_profile: {
              id: other_profile.id,
              display_name: other_profile.display_name,
              about_me: other_profile.about_me,
              genders: other_profile.genders,
              orientations: other_profile.orientations,
              languages: other_profile.languages,
              relationship_status: other_profile.relationship_status,
              relationship_type: other_profile.relationship_type,
              tobacco: other_profile.tobacco,
              alcohol: other_profile.alcohol,
              marijuana: other_profile.marijuana,
              other_recreational_drugs: other_profile.other_recreational_drugs,
              pets: other_profile.pets,
              wants_pets: other_profile.wants_pets,
              kids: other_profile.kids,
              wants_kids: other_profile.wants_kids,
              religion: other_profile.religion,
              religion_importance: other_profile.religion_importance,
              location_display_name: other_profile.location.display_name.transform_keys(&:to_sym),
              age: 39 # TODO: calculate this so that this test don't breaks when the profile ages
            }
          }
        ]
      }
      authorized_get @auth, format(@endpoint)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end

  describe "get /conversations/:id" do
    before do
      @endpoint = "/api/conversations/%<id>s"
      @auth = login(login: @login, password: @password)
    end
    it "gets a 400 if the id is not valid" do
      expected_response = {
        error: "VALIDATION_ERROR",
        details: [
          { fields: ["conversation_id"], errors: ["is invalid"] }
        ]
      }

      authorized_get @auth, format(@endpoint, id: "boo!")

      assert_predicate last_response, :bad_request?
      assert_response_schema_confirm(400)
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
    it "gets the single conversation" do
      other_profile = @account2.profile
      expected_response = {
        id: @conversation.id,
        created_at: @conversation.created_at.iso8601,
        last_seen_at: @conversation.profile1_last_seen_at.iso8601,
        other_profile: {
          id: other_profile.id,
          display_name: other_profile.display_name,
          about_me: other_profile.about_me,
          genders: other_profile.genders,
          orientations: other_profile.orientations,
          languages: other_profile.languages,
          relationship_status: other_profile.relationship_status,
          relationship_type: other_profile.relationship_type,
          tobacco: other_profile.tobacco,
          alcohol: other_profile.alcohol,
          marijuana: other_profile.marijuana,
          other_recreational_drugs: other_profile.other_recreational_drugs,
          pets: other_profile.pets,
          wants_pets: other_profile.wants_pets,
          kids: other_profile.kids,
          wants_kids: other_profile.wants_kids,
          religion: other_profile.religion,
          religion_importance: other_profile.religion_importance,
          location_display_name: other_profile.location.display_name.transform_keys(&:to_sym),
          age: 39 # TODO: calculate this so that this test don't breaks when the profile ages
        }
      }
      authorized_get @auth, format(@endpoint, id: @conversation.id)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
    it "gets the single conversation with an unseen message" do
      other_profile = @account2.profile
      create(:message, conversation: @conversation, sender: "profile2", content: "New message!!", sent_at: @conversation.profile1_last_seen_at + 1)

      expected_response = {
        id: @conversation.id,
        created_at: @conversation.created_at.iso8601,
        last_seen_at: @conversation.profile1_last_seen_at.iso8601,
        new_messages_preview: "New message!!",
        other_profile: {
          id: other_profile.id,
          display_name: other_profile.display_name,
          about_me: other_profile.about_me,
          genders: other_profile.genders,
          orientations: other_profile.orientations,
          languages: other_profile.languages,
          relationship_status: other_profile.relationship_status,
          relationship_type: other_profile.relationship_type,
          tobacco: other_profile.tobacco,
          alcohol: other_profile.alcohol,
          marijuana: other_profile.marijuana,
          other_recreational_drugs: other_profile.other_recreational_drugs,
          pets: other_profile.pets,
          wants_pets: other_profile.wants_pets,
          kids: other_profile.kids,
          wants_kids: other_profile.wants_kids,
          religion: other_profile.religion,
          religion_importance: other_profile.religion_importance,
          location_display_name: other_profile.location.display_name.transform_keys(&:to_sym),
          age: 39 # TODO: calculate this so that this test don't breaks when the profile ages
        }
      }
      authorized_get @auth, format(@endpoint, id: @conversation.id)

      assert_predicate last_response, :ok?
      assert_schema_conform(200)
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
  describe "get /conversations/:id/viewed" do
    before do
      @endpoint = "/api/conversations/%<id>s/viewed"
      @auth = login(login: @login, password: @password)
    end
    it "Updates the time for the first user" do
      last_seen_at = @conversation.profile1_last_seen_at
      authorized_put @auth, format(@endpoint, id: @conversation.id)

      assert_predicate last_response, :no_content?
      assert_schema_conform(204)
      @conversation.reload

      assert_operator last_seen_at, :<, @conversation.profile1_last_seen_at
    end
  end

  describe "get /conversations/:id/messages" do
    before do
      @endpoint = "/api/conversations/%<id>s/messages"
      @auth = login(login: @login, password: @password)
    end

    it "gets a 400 if min_id and max_id are not valid" do
      expected_response = {
        error: "VALIDATION_ERROR",
        details: [
          { fields: ["min_id"], errors: ["is invalid"] },
          { fields: ["max_id"], errors: ["is invalid"] }
        ]
      }
      authorized_get @auth, "#{format(@endpoint, id: @conversation.id)}?min_id=a&max_id=b"

      assert_predicate last_response, :bad_request?
      assert_response_schema_confirm(400)
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
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
      assert_schema_conform(200)
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
      assert_schema_conform(201)
      assert_equal expected_response, JSON.parse(last_response.body, symbolize_names: true)
    end
  end
end
