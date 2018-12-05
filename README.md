
# Micoverse Version 2

_TODO_

- Route all possible blockchain calls through API https://github.com/reidjs/microverse-api
  - jackpot
  - time remaining
  - round number
  - tile price
  - tile owner
  ...
- Change color
- Update rules
- Earn 1 million dollars :moneybag:

https://trello.com/b/yoEljv6Z/microverse

# Development 

## Contract Development
`cd eth`

`truffle migrate --reset`

## Frontend Development
`npm run serve`

`./scripts/migrate_artifacts.sh`

## Websockets
_Idea 1_
0. server keeps entire game state in memory
1. server watches either blockNumber or specific events 
2. server detects change in something (e.g., TilePriceChanged)
3. server broadcasts message with entire gamestate ({ jackpot: '48238', timeLeft: 993, ... })
4. clients receive message and update gamestate

_Idea 2_
1. server watches either blockNumber or specific events
2. server detects any event (e.g., TilePriceChanged)
3. server broadcasts message with specific event (type: 'TilePriceChanged' id: 4, value: 99923 })
4. clients receive message and update specific piece of state (e.g., tile price)
