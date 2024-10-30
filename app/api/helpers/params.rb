# frozen_string_literal: true

module API
  module Helpers
    # This module contain helpers for parameters to be used around the API
    module Params
      # @param params_hash [HashWithIndifferentAccess] A hash with params
      # @param key [String,Symbol] The key to coerce
      # @return [void] Description
      def coerce_empty_array_param_to_nil(params_hash, key)
        params_hash[key] = nil if params.key?(key) && params[key].blank?
      end
    end
  end
end
