PADbot
======

A(nother) Puzzle and Dragons IRC bot.

### Current Setup:
1) git clone  
2) set up RVM if you want, bundle install  
3) create an empty Postgres database for the app (I used 9.1)  
4) modify database_config.yaml to match the created database in (3)  
5) modify irc_config.yaml to tell the bot what to connect to  
6) ruby db_utils.rb import  
7) extra postgres stuff:

	a. enter postgres into your padbot db, then run the following to update your primary key sequence to the latest:
	SELECT setval('user_id_seq', (SELECT MAX(id) FROM users));

8) ruby PADbot.rb  

### Console Commands:  
ruby db_utils.rb export: Exports User and Monster data to JSON files  
ruby db_utils.rb import: Automatically initializes Postgres to contain data from provided JSON files  
ruby db_utils.rb console: Provides you with a Pry console with DataMapper in the namespace and initialized  
