const Microverse = artifacts.require("TestGameRounds");

const sleep = (milliseconds) => {
  return new Promise(resolve => setTimeout(resolve, milliseconds))
}

contract("Microverse", async (accounts) => {
  let microverse;

  beforeEach(() => {
    Microverse.deployed().then((instance) => microverse = instance)
  });

  describe("game round tests", async () => {

    // TODO:
    // - test round extension shrinking mechanism
    // - test jackpot distribution (i.e. jackpot ties)

    it("should extend game round on any action", async () => {
      let endTime1 = await microverse.roundEndTime();

      await sleep(1000)

      let tax = await microverse._priceToTax(100)
      await microverse.buyTile(1, 100, "0x0", {from: accounts[1], value: tax.toNumber()})
      let endTime2 = await microverse.roundEndTime();

      assert(endTime2.toNumber() > endTime1.toNumber())

      await sleep(1000)

      await microverse.setTilePrice(1, 100, "0x0", {from: accounts[1], value: tax.toNumber()})
      let endTime3 = await microverse.roundEndTime();

      assert(endTime3.toNumber() > endTime2.toNumber())
    })

  })
})
