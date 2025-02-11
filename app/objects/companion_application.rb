# frozen_string_literal: true

# This module accesses the configuration for the companion application.
# This is an application which will be in front and center of the main page. By default it is the RetroMeet web client, but it can be changed.
module CompanionApplication
  class << self
    # @return [String]
    def name
      ENV["COMPANION_APPLICATION_NAME"] || "RetroMeet Web"
    end

    # @return [String]
    def url
      ENV["COMPANION_APPLICATION_URL"] || "http://localhost:3001"
    end
  end
end
