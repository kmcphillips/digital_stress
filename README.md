# Digital Stress aka @Duck Discord bot

## Running

To run the bot:

```bash
bin/bot
```

A console is available with:

```bash
bin/console
```

From there you can call `run_bot` to connect to Discord, and `test_channel` to get a handle on a channel for testing.


## Installing

Install the ruby version with `mise`. There is no longer a `.ruby-version` file.


## Config

A config file is commited to the repo and written to disk in plain text. The `config/config.yml` is decrypted from `config/config.yml.enc` on run if it does not already exist. In production or other envs override the config file with the ENV var `DUCK_CONFIG_FILE` to something like `config/config.production.yml`.

The decryption key is either loaded from `config/config_key` or from the ENV var `DUCK_CONFIG_KEY`. The ENV var takes precedence.

To write the plain text config files to the encrypted ones, edit `config/config.yml` or `config/config.*.yml` etc. and run `bin/encrypt_config`. The changes can then be commited to the repo. To revert at anytime, delete the plain text config and it will be loaded from the encrypted version on run. Decrypting all config files can be forced by running `bin/decrypt_config`.


## Install to a Discord

```
https://discordapp.com/oauth2/authorize?&client_id=<CLIENT_ID>&scope=bot&permissions=8
```
Where `<CLIENT_ID>` is the `client_id` for the application registered in discord.


## Deploy

```bash
fly deploy
```

## Database

Some static data is stored in SQLite instances, but those are read only, such as D&D data.

Transactional data uses a MySQL DB. Start by creating the user with something like:

```sql
CREATE DATABASE digital_stress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'digital_stress_user'@'%' IDENTIFIED BY '12345';
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES ON digital_stress_db.* TO 'digital_stress_user'@'%' WITH GRANT OPTION;
```

And initialize the DB with the schema in `duck.mysql.sql`.

To execute something like modifying the tables, use `bin/console` and run:
```ruby
sql_statement = "ALTER TABLE ..."
Global.db.execute(sql_statement).to_a
```

Some messages are omitted from being recorded based on filters. If those filters are updated, run:

```ruby
Recorder.delete_sweep
```

## Factorio mod

To release the mod in the format Factorio expects it to be uploaded:

```bash
cd factorio_mod
zip -r duck_x.y.z.zip duck
```

## Tests

Create a MySQL database configured in `config_spec.yml` and load it with `duck.mysql.sql`.
