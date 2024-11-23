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
  describe ".insert_message" do
    it "tries to insert a message into a conversation that does not exist and fails" do
      profile_id = @account1.profile.id
      assert_raises Persistence::Repository::Messages::ConversationNotFound do
        Persistence::Repository::Messages.insert_message(conversation_id: "11111111-1111-7111-b111-111111111111", profile_id:, content: "oh hi")
      end
    end
    it "tries to insert a message into a conversation but the sender does not belong and fails" do
      profile_id = @account2.profile.id
      assert_raises ArgumentError do
        Persistence::Repository::Messages.insert_message(conversation_id: @conversation.id, profile_id:, content: "oh hi")
      end
    end
    it "inserts a message into a conversation with the first profile" do
      profile_id = @account1.profile.id
      inserted_message = assert_difference "Message.count", 1 do
        Persistence::Repository::Messages.insert_message(conversation_id: @conversation.id, profile_id:, content: "oh hi")
      end
      message = Message.find(id: inserted_message[:id])

      assert_equal "profile1", message.sender
      assert_equal profile_id, inserted_message[:sender]
    end
    it "inserts a message into a conversation with the second profile" do
      profile_id = @account3.profile.id
      inserted_message = assert_difference "Message.count", 1 do
        Persistence::Repository::Messages.insert_message(conversation_id: @conversation.id, profile_id:, content: "oh hi")
      end
      message = Message.find(id: inserted_message[:id])

      assert_equal "profile2", message.sender
      assert_equal profile_id, inserted_message[:sender]
    end
  end

  describe ".find_conversations" do
    before do
      @conversation1 = create(:conversation, profile1_id: @account1.profile.id, profile2_id: @account2.profile.id)
      @conversation2 = create(:conversation, profile1_id: @account2.profile.id, profile2_id: @account3.profile.id)
    end

    it "find all conversations from a profile" do
      conversations = Persistence::Repository::Messages.find_conversations(profile_id: @account2.profile.id)

      assert_equal 2, conversations.size
    end
  end

  describe ".find_messages" do
    before do
      create(:message, conversation: @conversation, sender: "profile1", content: "Message 1")
      create(:message, conversation: @conversation, sender: "profile2", content: "Message 2")
      @message3 = create(:message, conversation: @conversation, sender: "profile1", content: "Message 3")
      create(:message, conversation: @conversation, sender: "profile1", content: "Message 4")
      create(:message, conversation: @conversation, sender: "profile2", content: "Message 5")
    end

    it "find all messages for a conversation" do
      messages = Persistence::Repository::Messages.find_messages(conversation_id: @conversation.id)
      expected_messages = ["Message 5", "Message 4", "Message 3", "Message 2", "Message 1"]

      assert_equal 5, messages.size
      assert_equal(expected_messages, messages.map { |v| v[:content] })
    end

    it "paginate messages for a conversation" do
      messages = Persistence::Repository::Messages.find_messages(conversation_id: @conversation.id, max_id: @message3.id)

      expected_messages = ["Message 2", "Message 1"]

      assert_equal 2, messages.size
      assert_equal(expected_messages, messages.map { |v| v[:content] })
    end
  end
end
