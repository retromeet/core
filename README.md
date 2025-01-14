# RetroMeet

RetroMeet is a free, open-source dating and friend-finding application. RetroMeet has a philosophy of giving more space to give more information about yourself and to help find people who share common interests with you. The whole philosophy of RetroMeet is described in [the philosophy](https://join.retromeet.social/philosophy).

This repository contains the RetroMeet core. This component provides an API to access the app functionalities without any external interface.

## Development

RetroMeet is written in Ruby. Currently, instructions are only available to run RetroMeet without any kind of virtualization. Feel free to submit a PR to add to our instructions ;)

### Linting

We use Rubocop for linting. To make your experience easier, it's recommended that you enable rubocop in your IDE, depending on your IDE the way to do that might be different, but most of the Ruby Language servers support rubocop, so you should be able to enable it whether you're using NeoVim or VScode.

There's a [pronto](https://github.com/prontolabs/pronto) github action running on each pull request that will comment on any forgotten lint issues. You can also get ahead of it by enabling [lefthook](https://github.com/evilmartians/lefthook), you can do it by running locally: `lefthook install --force`. The `--force` is optional, but will override any other hooks you have in this repo only, so it should be safe to run. This will run pronto any time you try to push a branch.

When contributing, you are welcome to fix pre-existing lint issues in files. But it is better if you open a separate pull request for fixing up linting issues that are not related to the code you are touching, to simplify the reviewing process.

### Setup

RetroMeet requires Postgresql >= 16.0 (it might work with a lower version than that, but it is not guaranteed), PostGIS >= 3.4 (again, might work with a lower version, but not guaranteed) and the [pg_uuidv7](https://github.com/fboulnois/pg_uuidv7) extension.

First, we need to set up the database. RetroMeet uses [rodauth](https://github.com/jeremyevans/rodauth), the following instructions will create the needed users, database and extensions needed for roda.
1. Create two users:
```sh
createuser -U postgres retromeet
createuser -U postgres retromeet_password
```
1. Create the database:
```sh
createdb -U postgres -O retromeet retromeet_dev
```
1. Load the citext extension:
```sh
psql -U postgres -c "CREATE EXTENSION citext" retromeet_dev
```
1. Load the postgis extension:
```sh
psql -U postgres -c "CREATE EXTENSION postgis" retromeet_dev
```
1. Load the pg_uuidv7 extension:
```sh
psql -U postgres -c "CREATE EXTENSION pg_uuidv7" retromeet_dev
```
1. Give the password user temporary rights to the schema:
```sh
psql -U postgres -c "GRANT CREATE ON SCHEMA public TO retromeet_password" retromeet_dev
```

Then, you need to run the following command so that the database set up:
```sh
rake db:setup
```

Finally, you need to revoke the temporary rights:
```sh
psql -U postgres -c "REVOKE CREATE ON SCHEMA public FROM retromeet_password" retromeet_dev
```

The same setup needs to be done for the test database, replacing `retromeet_dev` for `retromeet_test`:
```sh
createdb -U postgres -O retromeet retromeet_test
psql -U postgres -c "CREATE EXTENSION citext" retromeet_test
psql -U postgres -c "CREATE EXTENSION postgis" retromeet_test
psql -U postgres -c "CREATE EXTENSION pg_uuidv7" retromeet_test
psql -U postgres -c "GRANT CREATE ON SCHEMA public TO retromeet_password" retromeet_test
RACK_ENV=test rake db:setup
psql -U postgres -c "REVOKE CREATE ON SCHEMA public FROM retromeet_password" retromeet_test
```

### Database migrations

While working on the project, you might pull a newer version of `main` or merge a newer version of `main` into your branch which contains database modifications. To bring your database to the latest version, you need to migrate your database. You can do so by running:

```sh
bundle exec rake db:migrate
```

You need to do it for your test environment too, but you need to prepend the command with the variable that controls the environment:
```sh
APP_ENV=test bundle exec rake db:migrate
```

### Running tests

You can run all tests with:
```sh
bundle exec rake test
```

Or a single test by running it directly:
```sh
bundle exec ruby test/to/run.rb
```
