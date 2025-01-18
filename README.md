# Ruby War

## ♠ ♥ ♣ ♦

### usage 
```
irb
load('war.rb')
```


# play a single game
`play_game(false)`


# simulate a number of games
`simulate(game_count)`


uncomment puts statements to see the outcomes of a game in realtime (+various debugging statements that have been left in)
this gets ugly very fast when simulating > ~100 games, and fills the terminal taking forever to print, so I commented them.

TODOs? 

* utilize more class based methods to manipulate the game loop logic and sub functions instead of procedural messy code.
* add flag for printing out hands during each round.
* allow different rulesets  (1 card down during war, no shuffling, etc)
* improve stats and stats output format (generate csv or something)
