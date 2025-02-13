# frozen_string_literal: true

module Mails
  # Sends a notification for a sent message
  module ReportNotification
    class << self
      # Send a notification email about a new message in a conversation
      def deliver!(report_id:)
        admin_accounts = Persistence::Repository::Account.admin_accounts
        report = Persistence::Repository::Reports.find_full_report(id: report_id)
        notification_link = "/"

        template = Tilt.new("#{File.expand_path("../../mail/html", __dir__)}/report_notification.erb")
        body = template.render(Object.new, report:, notification_link:)

        email_subject_prefix = "RetroMeet: "
        admin_accounts.each do |to|
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
