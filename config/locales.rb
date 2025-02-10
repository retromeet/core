# frozen_string_literal: true

I18n.load_path += Dir["#{File.expand_path("locales", __dir__)}/*.yml"]
I18n.available_locales = %i[en pt-BR]
I18n.default_locale = :"pt-BR"
