PADbot
======

A(nother) Puzzle and Dragons IRC bot.

### Current Setup:
1) git clone  
2) set up RVM if you want, bundle isntall  
3) create an empty Postgres database for the app (I used 9.1)  
4) modify database_config.json to match the created database in (3)  
5) run importer.rb to seed the database with initial data  
6) edit PADbot.rb for IRC server, channel, nick settings  
7) ruby PADbot.rb  
