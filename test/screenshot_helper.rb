# frozen_string_literal: true

# This module is inspired by rails ScreenshotHelper, in: https://github.com/rails/rails/blob/main/actionpack/lib/action_dispatch/system_testing/test_helpers/screenshot_helper.rb
module ScreenshotHelper
  # Takes a screenshot of the current page in the browser.
  #
  # +take_screenshot+ can be used at any point in your system tests to take
  # a screenshot of the current state. This can be useful for debugging or
  # automating visual testing.
  #
  # The screenshot will be displayed in your console, if supported.
  #
  # You can set the +CAPYBARA_TESTING_SCREENSHOT+ environment variable to
  # control the output. Possible values are:
  # * [+inline+ (default)]    display the screenshot in the terminal using the
  #                           iTerm image protocol (http://iterm2.com/documentation-images.html).
  # * [+simple+]              only display the screenshot path.
  #                           This is the default value if the +CI+ environment variables
  #                           is defined.
  # * [+artifact+]            display the screenshot in the terminal, using the terminal
  #                           artifact format (http://buildkite.github.io/terminal/inline-images/).
  def take_screenshot
    save_image
    puts display_image
  end

  # Takes a screenshot of the current page in the browser if the test
  # failed.
  #
  # +take_failed_screenshot+ is included in <tt>application_system_test_case.rb</tt>
  # that is generated with the application. To take screenshots when a test
  # fails add +take_failed_screenshot+ to the teardown block before clearing
  # sessions.
  def take_failed_screenshot
    take_screenshot if failed? && supports_screenshot?
  end

  private

    def image_name
      failed? ? "failures_#{@NAME}" : @NAME
    end

    def absolute_image_path
      File.expand_path("../tmp/screenshots/#{image_name}.png", __dir__)
    end

    def save_image
      page.save_screenshot(absolute_image_path) # rubocop:disable Lint/Debugger
    end

    def output_type
      # Environment variables have priority
      output_type = ENV["CAPYBARA_TESTING_SCREENSHOT"] || ENV.fetch("CAPYBARA_INLINE_SCREENSHOT", nil)

      # If running in a CI environment, default to simple
      output_type ||= "simple" if ENV["CI"]

      # Default
      output_type ||= "inline"

      output_type
    end

    def display_image
      message = "[Screenshot]: #{absolute_image_path}\n"

      case output_type
      when "artifact"
        message << "\e]1338;url=artifact://#{absolute_image_path}\a\n"
      when "inline"
        name = inline_base64(File.basename(absolute_image_path))
        image = inline_base64(File.read(absolute_image_path))
        message << "\e]1337;File=name=#{name};height=400px;inline=1:#{image}\a\n"
      end

      message
    end

    def inline_base64(path)
      Base64.encode64(path).delete("\n")
    end

    def failed?
      !passed? && !skipped?
    end

    def supports_screenshot?
      Capybara.current_driver != :rack_test
    end
end
