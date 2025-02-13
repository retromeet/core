# frozen_string_literal: true

module Mails
  # Contains common methods to mails
  module Base
    # Returns a notification link to be sent in the notification email
    def generate_notification_link(payload)
      "#{EnvironmentConfig.companion_application_url}/notification?payload=#{Base64.urlsafe_encode64(payload.to_json)}"
    end
  end
end
