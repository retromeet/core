# RetroMeet

RetroMeet is a free, open-source dating and friend-finding application. RetroMeet has a philosophy of giving more space to give more information about yourself and to help find people who share common interests with you. The whole philosophy of RetroMeet is described in [the philosophy](https://join.retromeet.social/philosophy).

This repository contains the RetroMeet core. This component provides an API to access the app functionalities without any external interface.

## Development

RetroMeet is written in Ruby. Currently, instructions are only available to run RetroMeet without any kind of virtualization. Feel free to submit a PR to add to our instructions ;)

### Linting

We use Rubocop for linting. To make your experience easier, it's recommended that you enable rubocop in your IDE, depending on your IDE the way to do that might be different, but most of the Ruby Language servers support rubocop, so you should be able to enable it whether you're using NeoVim or VScode.

There's a [pronto](https://github.com/prontolabs/pronto) github action running on each pull request that will comment on any forgotten lint issues. You can also get ahead of it by enabling [lefthook](https://github.com/evilmartians/lefthook), you can do it by running locally: `lefthook install --force`. The `--force` is optional, but will override any other hooks you have in this repo only, so it should be safe to run. This will run pronto any time you try to push a branch.

### Setup

RetroMeet requires Postgresql >= 16.0 (it might work with a lower version than that, but it is not guaranteed).

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
