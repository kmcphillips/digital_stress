# Digital Stress - Discord bot

Add a `.env` with:
```
DISCORDRB_NONACL=false
DISCORDRB_TOKEN=<token>
AZURE_KEY=<token>
GIPHY_KEY=<token>
```

Then to run:

```
bundle exec main.rb
```

Install:

```
https://discordapp.com/oauth2/authorize?&client_id=639271437944750082&scope=bot&permissions=8
```

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
