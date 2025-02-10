# frozen_string_literal: true

require "minitest/test_task"

Minitest::TestTask.create(:test_unit) do |t|
  t.test_globs = ["test/app/**/*_test.rb"]
end
Minitest::TestTask.create(:test_capybara) do |t|
  t.test_globs = ["test/capybara/**/*_test.rb"]
end
task test: %i[test_unit test_capybara] do
  # Does nothing, only calls the other two tasks
end
task default: :test # Make testing the default task

require "grape-swagger/rake/oapi_tasks"
GrapeSwagger::Rake::OapiTasks.new("API::Base")

task :environment do # rubocop:disable Rake/Desc # We do not want to describe this one because it's only here as dependency for the other tasks
  require_relative "config/environment"
  Environment.load
  require_relative "config/zeitwerk"
end

namespace :db do
  task load: :environment do # rubocop:disable Rake/Desc # We do not want to describe this one because it's only here as dependency for the other tasks
    require_relative "config/database"
    require_relative "lib/rake_support/colors"
    require_relative "lib/rake_support/migrations"
  end

  desc "Sets up the database the first time. Should only be run once!"
  task setup: :load do
    Rake::Task["db:migrate"].invoke
    RakeSupport::Migrations.password_migrate(Database.ph_connection)
    RakeSupport::Migrations.dump_schema(Database.connection)
    puts RakeSupport::Colors.info.call("db:setup executed")
  end

  desc "Migrates the database up (options [version_number])"
  task :migrate, %i[version] => :load do |_, args|
    version = args[:version]&.to_i
    RakeSupport::Migrations.migrate(Database.connection, target_migration: version)
    RakeSupport::Migrations.dump_schema(Database.connection)

    puts RakeSupport::Colors.info.call("db:migrate executed")
  end

  desc "Migrates the database down (options [version_number])"
  task :"migrate:down", %i[version] => :load do |_, args|
    version = args[:version]&.to_i
    RakeSupport::Migrations.migrate_down(Database.connection, target_migration: version)
    RakeSupport::Migrations.dump_schema(Database.connection)

    puts RakeSupport::Colors.info.call("db:migrate:down executed")
  end

  desc "Creates a new migration file (parameters: NAME)"
  task :create, %i[name] => :load do |_, args|
    name = args[:name]
    if name.nil? || name.empty?
      puts RakeSupport::Colors.error.call("No NAME specified")
      puts RakeSupport::Colors.info.call <<~USAGE_STR.chomp
        Example usage
        `rake db:create[create_table]`
      USAGE_STR
      exit 1
    end
    fullpath = RakeSupport::Migrations.create_migration(name)

    puts RakeSupport::Colors.info.call("migration file created #{RakeSupport::Colors.warning.call(fullpath)}")
  end
end
