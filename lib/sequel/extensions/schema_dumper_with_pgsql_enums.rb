# frozen_string_literal: true

require "sequel/extensions/schema_dumper"

# This module includes Sequel::SchemaDumper to be dump pg_enums on top of the what
# the SchemaDumper already does. It's a quick hack, but it does the job.
module SchemaDumperWithPgsqlEnums
  include Sequel::SchemaDumper

  # @param (see Sequel::SchemaDumper.dump_schema_migration)
  # @return [String] The dumped scheam
  def dump_schema_migration(options = OPTS)
    enums = dump_enums
    schema_mig = super
    schema_mig.sub("change do", "change do\n#{enums}\n")
  end

  # Dumps the enums from the current database
  #
  # @return [String]
  def dump_enums
    @enum_labels.map do |oid, labels|
      enum_name = metadata_dataset.from(:pg_type).where(typcategory: "E", oid: oid).get(:typname)
      "create_enum(:#{enum_name}, [#{labels.map(&:inspect).join(",")}])"
    end.join("\n")
  end
  Sequel::Database.register_extension(:schema_dumper_with_pgsql_enums, SchemaDumperWithPgsqlEnums)
end
