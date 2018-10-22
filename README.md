Smart contract for a fun new game

## TODO
Contract:
- referrals
- add events
  - Pur
- (unit) testing. list high risk pieces below as I think of them
  - diminishing jackpot + round ending properly (incl. not being able to do certain actions when round has
    ended)
- perf testing of methods that iterate through all tiles
- figure out definition of 'team'

## Contract Development
`cd eth`
`truffle migrate --reset`
`./scripts/migrate_artifacts.sh`

## Frontend Development
`cd web`
`npm run serve`
