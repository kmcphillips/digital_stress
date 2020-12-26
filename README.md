# Digital Stress - Discord bot

Add a `config.yml` with:

```bash
cp config.example.yml config.yml
```

Then to run:

```bash
bundle exec main.rb
```

Install:

```
https://discordapp.com/oauth2/authorize?&client_id=<CLIENT_ID>&scope=bot&permissions=8
```
Where `<CLIENT_ID>` is the `client_id` for the application registered in discord.


Deploy:

```bash
bundle exec cap production deploy
```

Manage:

```bash
bundle exec cap production bot:start
bundle exec cap production bot:stop
bundle exec cap production bot:restart
```

Database:

```sql
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
CREATE TABLE train_accidents (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  timestamp INTEGER,
  user_id INTEGER,
  server VARCHAR(255),
  channel VARCHAR(255)
);
```

Clean up:

```ruby
Recorder.delete_sweep
```

Dump:

```ruby
File.open("dump_all.txt", "w"){|f|f.write(DB[:messages].map{|r|r[:message]}.reject{|m|m.blank?||(m.include?("✅")&&m.length<5)}.join("\n"))}
```

Release Factorio mod:

```bash
cd factorio_mod
zip -r duck_x.y.z.zip duck
```
