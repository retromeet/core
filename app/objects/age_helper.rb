# frozen_string_literal: true

# Contains helper functions around age
module AgeHelper
  class << self
    # @param birth_date [Date] The date to get the age from
    # @return [Integer] The age
    def age_from_date(birth_date)
      now = Time.now.utc.to_date
      extra_year_or_not = 1
      extra_year_or_not = 0 if now.month > birth_date.month || (now.month == birth_date.month && now.day >= birth_date.day)
      now.year - birth_date.year - extra_year_or_not
    end
  end
end
