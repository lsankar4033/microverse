const Microverse = artifacts.require("TestAuction");

async function calculateTotalBuyPrice(tilePrice, newPrice, microverse) {
  let tax = await microverse._priceToTax(newPrice)
  return tax.toNumber() + tilePrice.toNumber()
}

contract("Microverse", async (accounts) => {
  let microverse;

  beforeEach(() => {
    Microverse.deployed().then((instance) => microverse = instance)
  });

  describe("auction tests", async () => {

    it("buyer must pay tax based on new price setting", async () => {
      let tileId = 1
      let tilePrice = await microverse.getTilePriceAuction()
      let newPrice = 1000

      try {
        await microverse.buyTileAuction(tileId, newPrice, {from: accounts[2], value: tilePrice})
        assert(false)
      } catch (e) {
      }

      let totalPrice = await calculateTotalBuyPrice(tilePrice, newPrice, microverse)
      await microverse.buyTileAuction(tileId, newPrice, {from: accounts[2], value: totalPrice})

      let actualNewPrice = await microverse.tileToPrice(1)
      assert.equal(newPrice, actualNewPrice.toNumber())

      let newOwner = await microverse.tileToOwner(1)
      assert.equal(newOwner, accounts[2])
    })

    it("each time can only be bought once", async () => {
      let tileId = 2
      var tilePrice = await microverse.getTilePriceAuction();
      var newPrice = 1000

      var totalPrice = await calculateTotalBuyPrice(tilePrice, newPrice, microverse)
      await microverse.buyTileAuction(tileId, newPrice, {from: accounts[2], value: totalPrice})

      // TODO: Try buying again from another account
      tilePrice = await microverse.getTilePriceAuction();
      newPrice = 100

      totalPrice = await calculateTotalBuyPrice(tilePrice, newPrice, microverse)

      try {
        await microverse.buyTileAuction(tileId, newPrice, {from: accounts[3], value: totalPrice})
        assert(false)
      } catch (e) {
      }
    })

  })

})
