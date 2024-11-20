# frozen_string_literal: true

require_relative "../../../test_helper"

describe Persistence::Repository::Messages do
  before(:all) do
    @schaerbeek = create(:location, latitude: 50.8676041, longitude: 4.3737121, language: "en", name: "Schaerbeek - Schaarbeek, Brussels-Capital, Belgium", country_code: "be", osm_id: 58_260)
    @account1 = create(:account, profile: { location_id: @schaerbeek.id })
    @account2 = create(:account, profile: { location_id: @schaerbeek.id })
    @account3 = create(:account, profile: { location_id: @schaerbeek.id })
    @conversation = create(:conversation, profile1: @account1.profile, profile2: @account3.profile)
  end

  describe ".upsert_conversation" do
    it "calls for a conversation that does not exist yet" do
      profile1_id = @account1.profile.id
      profile2_id = @account2.profile.id

      assert_difference "Conversation.count", 1 do
        Persistence::Repository::Messages.upsert_conversation(profile1_id:, profile2_id:)
      end
    end
    it "calls upsert for both directions but only gets one new conversation" do
      profile1_id = @account1.profile.id
      profile2_id = @account2.profile.id

      assert_difference "Conversation.count", 1 do
        conversation_id1 = Persistence::Repository::Messages.upsert_conversation(profile1_id:, profile2_id:)
        conversation_id2 = Persistence::Repository::Messages.upsert_conversation(profile1_id: profile2_id, profile2_id: profile1_id)

        assert_equal conversation_id1, conversation_id2
      end
    end
    it "calls upsert for a conversation that already exists and gets the existing id back" do
      profile1_id = @account1.profile.id
      profile2_id = @account3.profile.id

      conversation_id = assert_difference "Conversation.count", 0 do
        Persistence::Repository::Messages.upsert_conversation(profile1_id:, profile2_id:)
      end
      assert_equal @conversation.id, conversation_id
    end
    it "calls upsert for a conversation with the same profile on both sides and gets an error" do
      profile1_id = @account1.profile.id
      profile2_id = @account1.profile.id

      assert_raises ArgumentError do
        Persistence::Repository::Messages.upsert_conversation(profile1_id:, profile2_id:)
      end
    end
  end
end
