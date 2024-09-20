# frozen_string_literal: true

require_relative "lib/rake_support/load_env"
require_relative "config/database"
require_relative "lib/rake_support/colors"
require_relative "lib/rake_support/migrations"
require "minitest/test_task"

Minitest::TestTask.create

namespace :db do
  desc "Sets up the database the first time. Should only be run once!"
  task :setup do
    Rake::Task["db:migrate"].invoke
    RakeSupport::Migrations.password_migrate(Database.ph_connection)
    RakeSupport::Migrations.dump_schema(Database.connection)
    puts RakeSupport::Colors.info.call("db:setup executed")
  end

  desc "Migrates the database up (options [version_number])"
  task :migrate, [:version] do |_, args|
    version = args[:version]&.to_i
    RakeSupport::Migrations.migrate(Database.connection, target_migration: version)
    RakeSupport::Migrations.dump_schema(Database.connection)

    puts RakeSupport::Colors.info.call("db:migrate executed")
  end

  desc "Migrates the database down (options [version_number])"
  task :"migrate:down", [:version] do |_, args|
    version = args[:version]&.to_i
    RakeSupport::Migrations.migrate_down(Database.connection, target_migration: version)
    RakeSupport::Migrations.dump_schema(Database.connection)

    puts RakeSupport::Colors.info.call("db:migrate:down executed")
  end

  desc "Creates a new migration file (parameters: NAME)"
  task :create, [:name] do |_, args|
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
