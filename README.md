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

Transactional data uses a MySQL DB with the following:

```sql
CREATE DATABASE digital_stress_db CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
CREATE USER 'digital_stress_user'@'%' IDENTIFIED BY '12345';
GRANT CREATE, ALTER, DROP, INSERT, UPDATE, DELETE, SELECT, REFERENCES ON digital_stress_db.* TO 'digital_stress_user'@'%' WITH GRANT OPTION;

CREATE TABLE messages (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  timestamp INTEGER,
  user_id INTEGER,
  username VARCHAR(255),
  message TEXT ,
  server VARCHAR(255),
  channel VARCHAR(255),
  message_id INTEGER
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE learned (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  timestamp BIGINT,
  user_id BIGINT,
  message TEXT,
  server VARCHAR(255),
  channel VARCHAR(255),
  message_id BIGINT
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE train_accidents (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  timestamp BIGINT,
  user_id BIGINT,
  server VARCHAR(255),
  channel VARCHAR(255)
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE announcements (
  id INTEGER AUTO_INCREMENT PRIMARY KEY,
  server VARCHAR(255),
  channel VARCHAR(255),
  day INTEGER,
  month INTEGER,
  year INTEGER,
  message TEXT,
  guild_scheduled_event_id BIGINT,
  google_calendar_id VARCHAR(255)
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE TABLE redis_0 (
  `key` VARCHAR(255),
  value TEXT,
  timestamp BIGINT
) CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;
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
