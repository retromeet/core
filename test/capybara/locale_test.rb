# frozen_string_literal: true

require_relative "../capybara_helper"

class LocaleTest < CapybaraTestCase
  def login(login: Faker::Internet.email)
    visit "/login"

    assert_text "Forgot Password?"

    fill_in("login", with: login)
    fill_in("Password", with: "password")
    within("form") do
      click_on("Login")
    end

    assert_text "You have been logged in"
  end

  it "visits the main page and see buttons in english" do
    visit "/"

    assert_text("Login")
    assert_text("Sign up")
  end

  it "Logs in with an account that has pt-br as preferences and sees buttons in portuguese" do
    account = create(:account, profile_preference: { preferences: { locale: "pt-BR" } })
    login(login: account.email)
    visit "/"

    assert_button("Encerrar sessão")
  end
end
