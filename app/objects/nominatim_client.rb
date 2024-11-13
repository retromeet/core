# frozen_string_literal: true

# This modules contains functions to interact with the {https://wiki.openstreetmap.org/wiki/Nominatim Nominatim} backend.
# The backend is configured through ENV variables and will use the default backend otherwise.
module NominatimClient
  MAX_SEARCH_RESULTS = 10

  class << self
    # @param query [String] A query to be sent to nominatim
    # @param limit [Integer] The max results to return
    # @param language [String] The language for the results
    def search(query:, limit: MAX_SEARCH_RESULTS, language: "en")
      params = {
        q: CGI.escape(query),
        format: :jsonv2,
        language:,
        limit:,
        layer: :address,
        featureType: :settlement
      }
      query_params = params.map { |k, v| "#{k}=#{v}" }.join("&")
      results = Sync do
        response = client.get("/search?#{query_params}", headers: base_headers)
        # TODO: (renatolond, 2024-11-05) I'm not too sure of the result format, but it will do for now
        JSON.parse(response.read, symbolize_names: true)
      ensure
        response&.close
      end
      results.map do |result|
        {
          lat: result[:lat].to_f,
          lon: result[:lon].to_f,
          display_name: result[:display_name]
        }
      end
    end

    private

      # Returns the retromeet-core base host to be used for requests based off the environment variables
      # @return [Async::HTTP::Endpoint]
      def nominatim_host = @nominatim_host ||= Async::HTTP::Endpoint.parse("https://nominatim.openstreetmap.org")

      # @return [Hash] Base headers to be used for requests
      def base_headers = @base_headers ||= { "Content-Type" => "application/json", "User-Agent": RetroMeet::Version.user_agent }.freeze

      # @return [Async::HTTP::Client]
      def client = Async::HTTP::Client.new(nominatim_host)
  end
end
