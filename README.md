# RetroMeet

RetroMeet is a free, open-source dating and friend-finding application. RetroMeet has a philosophy of giving more space to give more information about yourself and to help find people who share common interests with you. The whole philosophy of RetroMeet is described in [the philosophy](docs/the_philosphy.md).

This repository contains the RetroMeet core. This component provides an API to access the app functionalities without any external interface.

## Development

RetroMeet is written in Ruby. Currently, instructions are only available to run RetroMeet without any kind of virtualization. Feel free to submit a PR to add to our instructions ;)

RetroMeet requires Postgresql >= 16.0 (it might work with a lower version than that, but it is not guaranteed).

First, we need to set up the database. RetroMeet uses [rodauth](https://github.com/jeremyevans/rodauth), the following instructions will create the needed users, database and extensions needed for roda.
1. Create two users:
```sql
createuser -U postgres retromeet
createuser -U postgres retromeet_password
```
1. Create the database:
```sql
createdb -U postgres -O retromeet retromeet_dev
```
1. Load the citext extension:
```sql
psql -U postgres -c "CREATE EXTENSION citext" retromeet_dev
```
1. Give the password user temporary rights to the schema:
```sql
psql -U postgres -c "GRANT CREATE ON SCHEMA public TO retromeet_password" retromeet_dev
```

Then, you need to run the following command so that the database set up:
```sh
rake db:setup
```

Finally, you need to revoke the temporary rights:
```sql
psql -U postgres -c "REVOKE CREATE ON SCHEMA public FROM retromeet_password" retromeet_dev
```
