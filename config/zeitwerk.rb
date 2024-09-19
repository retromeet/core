# frozen_string_literal: true

# This API uses Zeitwerk to load code. You can see more about how Zeitwerk works in https://github.com/fxn/zeitwerk,
# but basically this will add a few directories where files can be and zeitwerk will load it automatically using inflection rules.
loader = Zeitwerk::Loader.new
loader.push_dir "./app/"
loader.push_dir "./config/"
loader.inflector.inflect("api" => "API")
loader.inflector.inflect("authenticated_api" => "AuthenticatedAPI")
loader.setup
