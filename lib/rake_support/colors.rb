# frozen_string_literal: true

module RakeSupport
  # Helper module for using the same colors across the rake errors
  module Colors
    class << self
      # @return [Pastel::Detached]
      def info
        @info ||= pastel.cyan.detach
      end

      # @return [Pastel::Detached]
      def error
        @error ||= pastel.red.bold.detach
      end

      # @return [Pastel::Detached]
      def warning
        @warning ||= pastel.yellow.detach
      end

      private

        # @return [Pastel]
        def pastel
          @pastel ||= Pastel.new
        end
    end
  end
end
