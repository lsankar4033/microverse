Smart contract for a fun new game

## TODO
Contract:
- add events
  - Pur
- (unit) testing. list high risk pieces below as I think of them
  - diminishing jackpot + round ending properly (incl. not being able to do certain actions when round has
    ended)

## Contract Development
`cd eth`
`truffle migrate --reset`

## Frontend Development
`cd web`

`npm run serve`

`./scripts/migrate_artifacts.sh`

_TODO_

- Make tiles reactive to events
- Test game transitions (auction -> game rounds)
- Figure out how to appropriately set `gas` on transactions. Always seems to fail for certain combinations of buy price + tax + newPrice
- Add How To Play (rules) copy
