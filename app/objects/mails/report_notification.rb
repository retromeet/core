# frozen_string_literal: true

module Mails
  # Sends a notification for a sent message
  module ReportNotification
    extend Mails::Base

    class << self
      # Send a notification email about a new message in a conversation
      def deliver!(report_id:)
        admin_account_emails = Persistence::Repository::Account.admin_account_emails
        report = Persistence::Repository::Reports.find_full_report(id: report_id)

        notification_link = generate_notification_link(notification_info: { type: :report, profile_id: report[:target_profile_id] })

        template = Tilt.new("#{File.expand_path("../../mail/html", __dir__)}/report_notification.erb")
        body = template.render(Object.new, report:, notification_link:)

        email_subject_prefix = "RetroMeet: "
        admin_account_emails.each do |to|
          m = Mail.new do
            from EnvironmentConfig.smtp_from_address
            to to
            subject "#{email_subject_prefix}#{I18n.t("emails.report_notification.subject")}"
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
end
