# frozen_string_literal: true

if Environment.development?
  Mail.defaults do
    delivery_method LetterOpener::DeliveryMethod, location: File.expand_path("../tmp/letter_opener", __dir__)
  end
end
