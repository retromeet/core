# frozen_string_literal: true

Database.connection # Call the connection once to create the connection before the truncation below
DatabaseCleaner[:sequel].clean_with :truncation
# Seed the test database:
Database.connection[:account_statuses].import(%i[id name], [[1, "Unverified"], [2, "Verified"], [3, "Closed"]])

DatabaseCleaner[:sequel].strategy = :transaction

class Minitest::HooksSpec # rubocop:disable Style/ClassAndModuleChildren
  before :all do
    DatabaseCleaner[:sequel].start
  end

  before :each do
    DatabaseCleaner[:sequel].start
  end

  after :each do
    DatabaseCleaner[:sequel].clean
  end

  after :all do
    DatabaseCleaner[:sequel].clean
  end
end
