# frozen_string_literal: true

# This API uses Zeitwerk to load code. You can see more about how Zeitwerk works in https://github.com/fxn/zeitwerk,
# but basically this will add a few directories where files can be and zeitwerk will load it automatically using inflection rules.
loader = Zeitwerk::Loader.new
loader.push_dir "./app/"
loader.push_dir "./config/"
loader.collapse "./app/objects/"
loader.inflector.inflect("api" => "API")
loader.inflector.inflect("authenticated_api" => "AuthenticatedAPI")
loader.inflector.inflect("retromeet" => "RetroMeet")
loader.ignore("#{__dir__}/locales.rb")
loader.setup

loader.eager_load if Environment.current == :production
