# frozen_string_literal: true

require_relative "test_helper"

WebMock.disable_net_connect!(allow_localhost: true)
WebMock.stub_request(:any, //)
       .with { |request| !selenium_request?(request) }
       .to_return { |req| raise WebMock::NetConnectNotAllowedError.new(WebMock::RequestSignature.new(req.method, req.uri, body: req.body, headers: req.headers)) } # rubocop:disable Style/RaiseArgs

# Checks if a request that got to webmock is probably made by selenium.
# @return [Boolean] Description
def selenium_request?(request)
  request.headers["User-Agent"].match?(%r{^selenium/}i) || (
    # The selenium driver sends a final "shutdown" request where the user
    # agent header is wrong, so allow that too.
    request.uri.host == "127.0.0.1" &&
    ["/shutdown", "/__identify__"].include?(request.uri.path) &&
    request.headers["User-Agent"] == "Ruby"
  )
end

Capybara.configure do |config|
  config.server = :falcon_http
  config.enable_aria_label = true
end

Capybara.register_driver :selenium_chrome do |app|
  headless = ENV.fetch("HEADLESS", true) != "false"
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument("--headless") if headless
  options.add_argument("--no-sandbox")
  options.add_argument("--disable-dev-shm-usage")
  options.add_argument("--disable-gpu")
  options.add_argument("--window-size=1400,1400")
  driver = Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
  driver
end

Capybara.app = RackHelper.app
Capybara.default_driver = :selenium_chrome
require "capybara/minitest"

require_relative "screenshot_helper"

class CapybaraTestCase < Minitest::Spec
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include ScreenshotHelper

  def teardown
    take_failed_screenshot
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
