# frozen_string_literal: true

namespace :retromeet do
  desc "Make a profile with the given id into an admin"
  task :make_admin, %i[email] => :environment do |_, args|
    require_relative "../rake_support/colors"
    Persistence::Repository::Account.make_admin(email: args[:email])

    puts RakeSupport::Colors.info.call("#{args[:email]} is now an admin")
  end
end
