PADbot
======

```
<FrickenMoron> !pad roll a joint
<asterbot> Unable to roll a joint
```

A(nother) Puzzle and Dragons IRC bot.

### Command Documentation
* !pad help: lists plugins associated with Asterbot. Some naming confusion, because plugins have multiple keywords. I have reproduced the most popular ones in here.
```
<Asterism> !pad help
<asterbot> Known plugins (!pad HELP name for detailed information): register, lookup, mats_for, mats, help, rank, batrem, news, group, time, stamina, kitty, exp, wireshark, rem, chain, tags, who, query, skillup, gacha, apropos, echo, calc, settopic, tomorrow, dailies, when
```
* !pad help [command]: displays internal help information for a specific command.
```
<Asterism> !pad help apropos
<asterbot> !pad which [NAME]: Returns a set of all monster names which contain NAME as a substring.
<asterbot> !pad which [red|blue|green|light|dark] [NAME]: Filter monsters by PRIMARY color.
<asterbot> Yes, this could be a bit awkward if you're looking for a monster whose name begins with, say, 'red'.
```

#### Users
* !pad register [username] [fc] [padherder_name]: registers a certain username (distinct from your IRC) nick together with a required PAD friend code and an optional padherder username, which may be the same as the registered username.
```
<Asterism> !pad register asterbot 123456789
<asterbot> Created asterbot with FC 123456789.
```
* !pad register alias [username]: registers your CURRENT IRC nick as an alias of the provided username. Aliases may be used whenever another call requires a username.
```
<Alterism> !pad register alias Asterism
<asterbot-mk2> Associated asterism with new alias Alterism.
```
* !pad register padherder [padherder_name]: registers a padherder account name with the account matching your current IRC nick. Yes, it's awkward. I'll fix it eventually. In any case, this should only be used for legacy users registered before padherder integration.
```
!pad register padherder aster@SA/PG/REDDIT/FARK/DIGG
```
* !pad who: prints your friend code and padherder home page (if known) into the current IRC channel.
```
<Asterism> !pad who
<asterbot> asterism's code is 367944265
<asterbot> asterism's padherder page is https://www.padherder.com/user/Asterism
```
* !pad who [username]: prints the friend code and padherder home page (if known) of another user.
```
<Asterism> !pad who asterbot
<asterbot> asterbot's code is 123456789
```
* !pad group [username]: prints the urgent dungeon group associated with a given user's friend code in NA.
```
<Asterism> !pad group asterism
<asterbot> asterism's group is C
```

#### Lookup
* !pad which [search_key]: prints the list of all monsters with names that contain search_key.
```
<Asterism> !pad which isis
<asterbot> Matches found: #492 Isis (5*), #493 Water Deity, Holy Isis (6*), #996 Blue Moon Sea Deity, Isis (7*), #997 Shining Sea Deity, Isis (7*), #2017 Scholarship Student Isis (7*), #2023 water deity, holy isis (4*)
```
* !pad which [color] [search_key]: prints the list of all monsters with names that contain search_key, that have the specified main element.
```
<Asterism> !pad which green zhuge
<asterbot> Matches found: #1372 Sleeping Dragon, Zhuge Liang (5*), #1373 Genius Sleeping Dragon, Zhuge Liang (6*), #1714 sleeping dragon, zhuge liang (4*), #1715 genius sleeping dragon, zhuge liang (5*)
```
* !pad lookup [monster]: displays detailed information about the specified monster.
```
<Asterism> !pad lookup green_evolved hades
<asterbot> [-] #1748 Awoken Hades, a 7* Dark/Wood Devil/Attacker monster.
<asterbot> Deploy Cost: 30. Max level: 99, 4000000 XP to max.
<asterbot> Awakenings: Enhanced Dark Orbs, Resistance-Dark, Skill Boost, Enhanced Dark Att., Two-Pronged Attack, Two-Pronged Attack, Enhanced Wood Orbs, Resistance-Dark
<asterbot> HP 1140-2471, ATK 777-1860, RCV 158-396, BST 2075-4727
<asterbot> (Active) Gravity World: Reduce 25% of all enemies' HP. Ignore enemy element and defense. Increases time limit of orb movement by 5 seconds for 1 turn. (13-17 turns)
<asterbot> (Leader) Divine Purgatory Magic: Dark attribute & Devil type cards ATK x2.5. 50% Wood & Dark damage reduction.
```
* !pad query [monster] [fact]: displays a certain fact about the specified monster. The following facts are supported: NAME, ID, STARS, ELEMENT, TYPES, COST, AWAKENINGS, SKILL, LEADER, STATS, HP, ATK, RCV, BST.
```
<Asterism> !pad query 6* ronia awakening
<asterbot> Extant Red Dragon Caller, Sonia awakening => Enhanced Fire Att., Enhanced Dark Att., Recover Bind, Skill Boost, Skill Boost
``` 
* !pad chain [monster]: displays the full branching evolution chain for the specified monster.
```
<Asterism> !pad chain hades
<asterbot> Hades, Underlord Hades, Underlord Arch Hades, Underlord Inferno Hades, Awoken Hades
```
* !pad mats [monster]: displays all possible evolutions for the specified monster, together with the materials required to evolve.
```
<Asterism> !pad mats underworld hades
<asterbot> Underlord Hades materials: Dub-topalit, Dub-topalit, Dub-topalit, Dub-mythlit, Keeper of Rainbow | Dub-mythlit, Keeper of Rainbow, Dub-amelit, Dub-amelit, Dub-amelit | Awoken Gaia, Ancient Green Sacred Mask, Awoken Zeus Stratios, Divine Onyx Mask, Divine Onyx Mask
```
* !pad mats_for [monster]: displays the materials required to evolve into the specified monster, from its previous form.
```
<Asterism> !pad mats_for awoken hades
<asterbot> Underlord Hades => Awoken Hades materials: Awoken Gaia, Ancient Green Sacred Mask, Awoken Zeus Stratios, Divine Onyx Mask, Divine Onyx Mask
```
* !pad stamina [start] [end] [timezone]: calculates how much time it will take to get END stamina starting from START (default 0) and what time that will be. Specify your timezone in GMT, e.g -8 or +11.
```
<Asterism> !pad stamina 22 100 -8
<asterbot> You will gain 78 stamina (22-100) in ~780 minutes, or around 12:10PM UTC-08:00
```

#### Calculators
* !pad calc [expression]: evaluates a mathematical expression. Input is sanitized, so don't try anything frisky. Please keep in mind ruby numerical literal conventions (e.g use decimals if you want decimal answers).
```
<Asterism> !pad calc 2 + 100 / (3^4)
<asterbot> 2 + 100 / (3^4) = 3
<Asterism> !pad calc 2.0 + 100.0 / (3^4)
<asterbot> 2.0 + 100.0 / (3^4) = 3.235
```
* !pad exp [monster]: prints how much experience is required to max out a specific monster, and translates that into pengdras, kings, and supers.
```
<Asterism> !pad exp isis
<asterbot> To get Isis from 1 to 50 takes 707107xp, or 15.71/8.57/4.71 pengies/kings/supers. Get farming!
<Asterism> !pad exp evolved isis
<asterbot> To get Blue Moon Sea Deity, Isis from 1 to 99 takes 4000000xp, or 88.89/48.48/26.67 pengies/kings/supers. Get farming!
```
* !pad exp [monster] [current_level]: as above, but with a specific starting level instead of 1.
```
<Asterism> !pad exp evolved isis 60
<asterbot> To get Blue Moon Sea Deity, Isis from 60 to 99 takes 2875072xp, or 63.89/34.85/19.17 pengies/kings/supers. Get farming!
```
* !pad rank [rank]: displays the cumulative experience, friend count, and team cost associated with a specfic player rank.
```
<Asterism> !pad rank 167
<asterbot> Rank 167: cost 182, stamina 100, friends 50, total experience 5619714, next level in 81591
```
* !pad rank [from] [to]: displays the difference between two ranks, including a (probably) depressing accounting of the rank experience required in terms of KoG runs.
```
<Asterism> !pad rank 250 350
<asterbot> Ranks 250-350: cost +100, stamina +50, friends +0, experience +18566446. That's approximately 8197 stamina spent on KoG! That's over 28 straight days. Have fun!
```
* !pad skillup k N p: calculates the probability of getting k successful skillups in N feeds, given a skillup chance of p (defaults to 0.2).
```
<Asterism> !pad skillup 5 10 0.25
<asterbot> On 10 feeds (p=0.25), your odds of getting 5 or more successes is 0.078.
```
* !pad skillup K/c: calculates how many skillup feeders you must farm in order to get K skillups with probability c.
```
<Asterism> !pad skillup 8/0.9
<asterbot> Gathering 57 skill-up fodder will give you a 0.907 chance of 8 skill-ups.
```

#### Gachapon
* !pad tags: displays all known godfest tags, as well as reminder information about how to format them.
```
<Asterism> !pad tags
<asterbot> Use +[tags] to denote godfest; for example !pad roll +J2,G,O for a japanese 2.0/greek/odins fest.
<asterbot> Known tags: [R]oman, [J/J2]apanese, [I/I2]ndian, [N]orse, [E/E2]gyptian, [G]reek, [A/A2]ngels, [D]evils, [C]hinese, [3] Kingdoms, [H]eroes
<asterbot> [O]dins, [M]etatrons, [S]onias, G[U]an Yus, [Z]huges, [K]alis, [M]oirae, [@]ll Godfest-Only
```
* !pad rem [monster]: displays what PADbot belives to be true about a certain monster's eligability to be rolled in the gachapon module.
```
<Asterism> !pad rem avalon drake
<asterbot> I believe that Avalon Drake is available from the NA REM, but is not included in standard godfests
```
* !pad roll [godfest_tags]: simulates a single pull from the REM inside the provided godfest.
```
<Asterism> !pad roll +g,r,@
<asterbot> After 1 attempts, you rolled a Apollo. (There goes $5)
```
* !pad roll NUMBER [godfest_tags]: simulates NUMBER pulls from the REM inside the provided godfest, and prints only the gods you rolled.
```
<asterbot> You rolled 17 times (for $60) and got some gods:
<asterbot> Ares; Artemis; Venus
```
* !pad roll [search_key] [godfest_tags]: simulates pulls until you roll a monster whose name contains search_key, and tells you the (probably) depressing count and (almost certainly) depressing amount of money wasted.
```
<Asterism> !pad roll hanzo
<asterbot> After 295 attempts, you rolled a Hattori Hanzo. (There goes $1043)
```
* !pad kitty: simulates a single pull from the Sanrio collab REM.
```
<Asterism> !pad kitty
<asterbot> You got #1158 Kuromi.
```
* !pad batrem: simulates a single pull from the Batman Arkham Origins collab REM.
```
<Asterism> !pad batrem
<asterbot> You got #673 BAO Robin, the 4* G Balance. Womp womp.
```

### On Monster lookup
Any command which accepts a <monster> argument is enabled for fuzzy lookup. Fuzzy lookup allows you to correctly select the appropriate monster without ambiguity or confusion, without having to memorize fancy evolution titles or comma placement.  

To specify a monster for PADbot, you may provide either a string or an integer. Integers represent the same internal ID that PAD uses; 1 represents Tyrra, and so on. When given a string argument, PADbot will first attempt substring matches and then edit distance matches. Substring matches try to find a monster whose full name exactly includes the search term and then select the option which is closest to the search term in edit distance (this tends to favor unevolved gods, who lack fancy anime titles). Failing that, it will attempt to find a monster whose name is relatively close to the search term, again using edit distance. This can lead to amusing side-effects: for example, searching "trash" results in Raoh, since the two are only edit distance 2 apart (ditch the t and change the s to an o in "trash.") 

There are a certain number of pre-defined aliases which were intended to help with obvious nicknames ("red valkyrie" for #1270) but are deprecated because the manually curated list simply grew unmaintainable.  

In addition to the ID and name lookup, you may also add certain prefixes to the search query. "evolved" will select the maximally evolved form of the monster, selecting the ultimate evolution with lower ID in case of branches. "element_evolved" allows you to specify which ultimate evolution branch to take by subelement. "2*", "3*", "4*", and so on allow you to specify evolution level.

Here are some examples:

```
"911" => #911 Red Dragon Caller, Sonia
"evolved 911" => #1645 Marvelous Red Dragon Caller, Sonia
"valkyrie" => #225 Valkyrie
"5* valkyrie" => #226 Great Valkyrie
"evolved valkyrie" => #1727 Divine Law Goddess, Valkyrie Rose
"4* 1727" => #225 Valkyrie
"hovus" => #490 Horus
"evolved horus" => #994 Inferno Deity Falcon, Horus
"light_evolved horus" => #995 Blazing Deity Falcon, Horus
```

There are several monsters which remain impossible to practically specify using this syntax, generally as a result of monsters sharing the same name but having different colors (odins, metatrons, etc) or incredible ambiguity (the chibi monsters). Please use the !which command as a workaround, to find the correct ID to input.

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
