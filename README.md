# Setting up for the new year

## Modify database used in database.yml (Ignore warnings about db/test.sqlite3 already existing - it creates both dev and test databases)
```
rake db:create
rake db:migrate
```

## Bring up the server
```
rails s&
```

## Create Dave's scoring settings
```
curl -XPOST "http://localhost:3000/scoring_settings?passing_yards=0.05&int_thrown=-2&passing_td=6&misc_2pc=2&rush_yards=0.1&rush_td=6&fumbles_lost=-2&rec=0&rec_yards=0.1&return_yards=0.04&misc_td=6&rec_td=6&name=Dave%27s%20League" -d ''
```

## Create Bryans's scoring settings
```
curl -XPOST "http://localhost:3000/scoring_settings?passing_yards=0.04&int_thrown=-2&passing_td=6&misc_2pc=2&rush_yards=0.1&rush_td=6&fumbles_lost=-2&rec=0.5&rec_yards=0.1&return_yards=0&misc_td=6&rec_td=6&name=Bryan%27s%20League" -d ''
```

## Create Dave's league
```
curl -XPOST "http://localhost:3000/leagues?name=Dave2017&scoring_settings_id=1" -d ''
```

## Create Bryan's league
```
curl -XPOST "http://localhost:3000/leagues?name=Bryan2017&scoring_settings_id=2" -d ''
```

## Save players
Uncomment lines to hit the API
$12 - Go to http://www.fantasyfootballnerd.com/fantasy-football-api and upgrade to level 2
```
rails c
Players.save_players
```
## Save scores/rankings for a given scoring setting
```
rails c
PlayerScore.save_scores(scoring_setting_id)
PlayerScore.save_rankings(scoring_setting_id)
```

## Create a draft
```
curl -XPOST "http://localhost:3000/drafts?league_id=1" -d ''
```

## Initialize draft picks (creating a draft should do this)
```
DraftPick.initialize_draft_picks(2)
```

# Using the draft GUI
```
http://localhost:3000/player_scores?draft_id=4
```

