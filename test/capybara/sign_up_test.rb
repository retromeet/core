# frozen_string_literal: true

require_relative "../capybara_helper"

class AccountCreationTest < CapybaraTestCase
  def fill_in_fields(login: Faker::Internet.email, birth_date: Date.new(1997, 1, 1))
    fill_in("login", with: login)
    fill_in("Password", with: "my-password")
    fill_in("Confirm Password", with: "my-password")
    fill_in("birth_date", with: birth_date)
    click_on("Create Account")
    login
  end

  it "creating a new account" do
    visit "/create-account"

    login = fill_in_fields

    assert_text("Your account has been created")
    assert_instance_of Account, Account.find(email: login)
  end
  it "creating a new account, fails because it exists" do
    account = create(:account)

    visit "/create-account"

    fill_in_fields(login: account.email)

    assert_text("already an account with this login")
  end
  it "creating a new account, fails because of a bad login" do
    Capybara.current_driver = :rack_test
    visit "/create-account"

    login = fill_in_fields(login: "bad.email")

    assert_text("invalid login, does not meet requirements (not a valid email address)")
    assert_nil Account.find(email: login)
  end
  it "creating a new account, fails because it's too young" do
    visit "/create-account"

    login = fill_in_fields(birth_date: Date.today)

    assert_text("You need to be at least 18 years old to join")
    assert_nil Account.find(email: login)
  end
  it "creating a new account, fails because the date is invalid" do
    Capybara.current_driver = :rack_test
    visit "/create-account"

    login = fill_in_fields(birth_date: "2009-99-99")

    assert_text("must be a valid date")
    assert_nil Account.find(email: login)
  end
end
