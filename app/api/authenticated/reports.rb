# frozen_string_literal: true

module API
  module Authenticated
    # This class contains any reports-related endpoints
    class Reports < Grape::API
      namespace :reports do
        desc "Creates a report about a user. It can include messages or not",
             success: [code: 204, message: "Created successfully"],
             failure: Authenticated.failures([400, 401, 422, 500]),
             produces: Authenticated::PRODUCES,
             consumes: Authenticated::CONSUMES
        params do
          requires :target_profile_id, type: String, documentation: { format: :uuid }, regexp: Utils::UUID7_RE
          requires :type, type: String, values: Persistence::Repository::Reports::REPORT_TYPE_VALUES
          optional :comment, type: String, documentation: { desc: "The reason for the report, can be ommited." }
          optional :message_ids, type: [Integer], documentation: { desc: "Can include some messages by target_profile that are being reported" }, default: []
        end
        post "/" do
          Persistence::Repository::Reports.create(profile_id: logged_in_profile_id,
                                                  target_profile_id: params[:target_profile_id],
                                                  type: params[:type],
                                                  comment: params[:comment],
                                                  message_ids: params[:message_ids])
          status :no_content
        end
      end
    end
  end
end
