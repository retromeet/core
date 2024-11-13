# frozen_string_literal: true

# This modules contains functions to interact with the {https://photon.komoot.io/ Photon} backend.
# The backend is configured through ENV variables and will use the default backend otherwise.
module PhotonClient
  MAX_SEARCH_RESULTS = 10

  class << self
    # @param query [String] A query to be sent to nominatim
    # @param limit [Integer] The max results to return
    # @param language [String] The language for the results
    def search(query:, limit: MAX_SEARCH_RESULTS, language: "en")
      params = {
        q: CGI.escape(query),
        lang: language,
        limit:
      }
      layers = "layer=state&layer=county&layer=city&layer=district"
      query_params = params.map { |k, v| "#{k}=#{v}" }
      query_params << layers
      query_params = query_params.join("&")
      response = Sync do
        response = client.get("/api?#{query_params}", headers: base_headers)
        JSON.parse(response.read, symbolize_names: true)
      ensure
        response&.close
      end
      response[:features].map do |place|
        components = place[:properties].slice(*AddressComposer::AllComponents)
        components[:country_code] = place[:properties][:countrycode]
        components[:name] = place[:properties][:name]
        lon, lat = place[:geometry][:coordinates]
        display_name = AddressComposer.compose(components)
        display_name.chomp!
        display_name.gsub!("\n", ", ")
        {
          lat:,
          lon:,
          display_name:
        }
      end
    end

    private

      # Returns the photon host to be used for requests
      # @return [Async::HTTP::Endpoint]
      def photon_host = @photon_host ||= Async::HTTP::Endpoint.parse("https://photon.komoot.io")

      # @return [Hash] Base headers to be used for requests
      def base_headers = @base_headers ||= { "Content-Type" => "application/json", "User-Agent": RetroMeet::Version.user_agent }.freeze

      # @return [Async::HTTP::Client]
      def client = Async::HTTP::Client.new(photon_host)
  end
end
