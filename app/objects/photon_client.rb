# frozen_string_literal: true

# This modules contains functions to interact with the {https://photon.komoot.io/ Photon} backend.
# The backend is configured through ENV variables and will use the default backend otherwise.
module PhotonClient
  MAX_SEARCH_RESULTS = 10

  class << self
    # @param query [String] A query to be sent to nominatim
    # @param limit [Integer] The max results to return
    # @param language [String] The language for the results, can only be one of +supported_languages+.
    # @return [Array<Models::LocationResult>]
    def search(query:, limit: MAX_SEARCH_RESULTS, language: "en")
      language = normalize_language(language)
      params = {
        q: CGI.escape(query),
        lang: language,
        limit:
      }
      layers = "layer=state&layer=county&layer=city&layer=district"
      query_params = params.map { |k, v| "#{k}=#{v}" }
      query_params << layers
      query_params = query_params.join("&")
      results = Sync do
        response = client.get("/api?#{query_params}", headers: base_headers)
        JSON.parse(response.read, symbolize_names: true)
      ensure
        response&.close
      end
      results[:features].map do |place|
        components = place[:properties].slice(*AddressComposer::AllComponents)
        components[:country_code] = place[:properties][:countrycode]
        components[place[:properties][:osm_value]] = place[:properties][:name]
        longitude, latitude = place[:geometry][:coordinates]
        display_name = AddressComposer.compose(components)
        display_name.chomp!
        display_name.gsub!("\n", ", ")
        Models::LocationResult.new(
          latitude:,
          longitude:,
          display_name:,
          osm_id: place[:properties][:osm_id],
          country_code: components[:country_code]
        )
      end
    end

    private

      # The public photon API only supports a few languages (en, fr, de)
      # to support more languages another photon instance has to be used with a custom import
      # This will normalize any language not supported by the default endpoint to one of the supported ones
      # you can override the supported languages with the env variable defined below
      #
      # @param language (see .search)
      # @return [String]
      def normalize_language(language)
        return language if supported_languages.include?(language)

        supported_languages.first
      end

      # @return [Array<String>]
      def supported_languages
        @supported_languages ||= ENV.fetch("PHOTON_SUPPORTED_LANGUAGES", "en,fr,de").split(",")
      end

      # Returns the photon host to be used for requests
      # @return [Async::HTTP::Endpoint]
      def photon_host = @photon_host ||= Async::HTTP::Endpoint.parse(ENV.fetch("PHOTON_API_HOST", "https://photon.komoot.io"))

      # @return [Hash] Base headers to be used for requests
      def base_headers = @base_headers ||= { "Content-Type" => "application/json", "User-Agent": RetroMeet::Version.user_agent }.freeze

      # @return [Async::HTTP::Client]
      def client = Async::HTTP::Client.new(photon_host)
  end
end
