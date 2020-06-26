# Digital Stress - Discord bot

Add a `.env` with:
```
DISCORDRB_NONACL=false
DISCORDRB_TOKEN=<token>
AZURE_KEY=<token>
GIPHY_KEY=<token>
MANDATE_PERSONS=<json>
WEB_AUTH_USERNAME=<sinatra_username>
WEB_AUTH_PASSWORD=<sinatra_password>
WEB_NOTIFY_CHANNELS=<commat_list_of_channel_int_ids>
```

Then to run:

```
bundle exec main.rb
```

Install:

```
https://discordapp.com/oauth2/authorize?&client_id=<CLIENT_ID>&scope=bot&permissions=8
```
Where `<CLIENT_ID>` is the `client_id` for the application registered in discord.


Deploy:

```
bundle exec cap production deploy
```

Manage:

```
bundle exec cap production bot:start
bundle exec cap production bot:stop
bundle exec cap production bot:restart
```

Database:
```
CREATE TABLE messages (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER,
  user_id INTEGER,
  username VARCHAR(255),
  message TEXT,
  server VARCHAR(255),
  channel VARCHAR(255)
);
CREATE TABLE learned (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER,
  user_id INTEGER,
  message_id INTEGER,
  message TEXT,
  server VARCHAR(255),
  channel VARCHAR(255)
);
```
