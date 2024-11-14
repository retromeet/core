# frozen_string_literal: true

# This module automatically chooses the best Location Service based on the requested language
module LocationServiceProxy
  class << self
    # @param query [String] A query to be sent to nominatim
    # @param limit [Integer] The max results to return
    # @param language [String] The language for the results
    # @return [Array<Models::LocationResult>]
    def search(query:, limit: nil, language: "en")
      if PhotonClient.language_supported?(language)
        limit = PhotonClient::MAX_SEARCH_RESULTS if limit.nil?
        PhotonClient.search(query:, limit:, language:)
      else
        limit = NominatimClient::MAX_SEARCH_RESULTS if limit.nil?
        NominatimClient.search(query:, limit:, language:)
      end
    end
  end
end
