# frozen_string_literal: true

module RetroMeet
  module Config
    class << self
      # The RetroMeet core host. The one the user accesses to get to this server.
      # @return [String]
      def host
        # TODO: Make it not hard-coded!
        "http://localhost:3000"
      end
    end
  end
end
