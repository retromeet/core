# frozen_string_literal: true

module Mails
  # Sends a notification for a sent message
  module MessageNotification
    class << self
      # Send a notification email about a new message in a conversation
      def deliver!(conversation_id:, message:)
        conversation = Persistence::Repository::Messages.find_conversation(conversation_id:, profile_id: nil)
        receiver_id = if message[:sender] == conversation[:profile1_id]
          conversation[:profile2_id]
        else
          conversation[:profile1_id]
        end
        to = Persistence::Repository::Account.find_email_for(id: receiver_id)
        sender = Persistence::Repository::Account.basic_profile_info(id: message[:sender])
        notification_link = "/"

        template = Tilt.new("#{File.expand_path("../../mail/html", __dir__)}/message_received.erb")
        body = template.render(Object.new, sender:, message:, notification_link:)

        email_subject_prefix = "RetroMeet: "
        m = Mail.new do
          from EnvironmentConfig.smtp_from_address
          to to
          subject "#{email_subject_prefix}#{I18n.t("emails.message_notification.subject")}"
          html_part do
            content_type "text/html; charset=UTF-8"
            body body
          end
        end
        m.deliver!
      end
    end
  end
end
