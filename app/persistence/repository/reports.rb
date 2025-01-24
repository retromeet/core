# frozen_string_literal: true

module Persistence
  module Repository
    # Contains database logic around user reports
    module Reports
      extend Datasets
      ProfileNotFound = Class.new(StandardError)
      MessagesNotFoundOrNotFromSender = Class.new(StandardError)
      REPORT_TYPE_VALUES = %w[
        spam
        intimidation
        harassment
        minors
        against_rules
        illegal
        other
      ].freeze

      class << self
        # @param profile_id [String] The uuid for a profile
        # @param target_profile_id [String] The uuid for a profile
        # @param type [String] One of +REPORT_TYPE_VALUES+
        # @param comment [String,nil] The reason for report
        # @param message_ids [Array<Integer>,nil] Messages to be attached to the report
        # @raise [ProfileNotFound] If the target profile does not exist
        # @return [void]
        def create(profile_id:, target_profile_id:, type:, comment: nil, message_ids: [])
          raise ProfileNotFound unless profiles.where(id: target_profile_id).get(:id)

          message_ids ||= []
          found_message_ids = Messages.find_message_ids_with_sender(message_ids, target_profile_id)
          raise MessagesNotFoundOrNotFromSender unless found_message_ids == message_ids

          message_ids = Sequel.pg_array(message_ids, :bigint)
          reports.insert(profile_id:, target_profile_id:, type:, comment:, message_ids:)
        end
      end
    end
  end
end
