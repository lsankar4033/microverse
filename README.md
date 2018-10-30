Smart contract for a fun new game

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
