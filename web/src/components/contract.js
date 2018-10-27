// TODO: Figure out why certain txns fail due to gas.
const GAS_LIMIT = 3000000

class Contract {
  constructor(contractInstance) {
    this.instance = contractInstance
    this.tiles = {}
    this.gameStage = null
    this.jackpot = null
    this.auctionPrice = null
    this.update()
  }

  async update() {
    this.gameStage = await this.stage()
    if (this.gameStage == 0) this.auctionPrice = await this.getTilePriceAuction()
    // TODO: Can the gameStage potentially be higher than 1?
    if (this.gameStage == 1) this.jackpot = await this.getJackpot()
  }

  async getTile(id) {
    const owner = await this.tileToOwner(id)
    const price = await this.getTilePrice(id)
    const buyable = await this.tileIsBuyable(id)
    const loaded = true
    const tile = { owner, price, buyable, loaded, id }
    return tile
  }

  async getJackpot() {
    const jackpot = await this.instance.jackpot()
    return jackpot.toNumber()
  }

  async getBalance(address) {
    const payment = await this.instance.payments(address)
    return payment.toNumber()
  }

  async withdraw(address) {
    const transactionHash = await this.instance.withdrawPayments.sendTransaction({ from: address, gas: GAS_LIMIT })
    return transactionHash ? true : false
  }

  async stage() {
    const s = await this.instance.stage()
    return s.toNumber()
  }

  async getTimeRemaining() {
    const stage = await this.stage()
    if (stage === 0) {
      const rawStart = await this.instance.auctionStartTime()
      const start = rawStart.toNumber()
      const rawDuration = await this.instance.auctionDuration()
      const duration = rawDuration.toNumber()
      const end = start + duration
      const now = + new Date() / 1000
      return end - now
    }
    // instance.roundTimeRemaining() was always returning 24hr
    const rawEndTime = await this.instance.roundEndTime()
    const end = rawEndTime.toNumber()
    const now = + new Date() / 1000
    return end - now
  }

  async getTilePriceAuction() {
    const price = await this.instance.getTilePriceAuction()
    return price.toNumber()
  }

  async tileToPrice(id) {
    const price = await this.instance.tileToPrice(id)
    return price.toNumber()
  }

  async getTilePrice(id) {
    const stage = await this.stage()
    const owner = await this.tileToOwner(id)
    if (stage === 0 && !owner) return this.getTilePriceAuction()
    return this.tileToPrice(id)
  }

  async tileToOwner(id) {
    const owner = await this.instance.tileToOwner(id)
    const nullAddress = '0x0000000000000000000000000000000000000000'
    if (owner == nullAddress) return null
    return owner
  }

  async minTileId() {
    const min = await this.instance.minTileId()
    return min.toNumber()
  }

  async maxTileId() {
    const max = await this.instance.maxTileId()
    return max.toNumber()
  }

  async tileIsBuyable(id) {
    const stage = await this.stage()
    const owner = await this.tileToOwner(id)
    if (stage === 0 && owner) return false
    return true
  }

  async buyTile({ address, id, newPrice, referrer }) {
    const stage = await this.stage()
    let price
    let method
    let tax = 0
    let gas = GAS_LIMIT
    if (stage === 0) {
      price = await this.getTilePriceAuction()
      // TODO: Investigate if we need to charge tax here?
      price += await this.getTax(newPrice)
      method = this.instance.buyTileAuction
    } else {
      price = await this.tileToPrice(id)
      tax = await this.getTax(newPrice) + 1
      method = this.instance.buyTile
    }
    // TODO: Estimate gas instead of using hardcoded value to prevent errors
    // try {
    //   // This is silently failing if the tile has an owner.
    //   gas = await method.estimateGas(parseInt(id), parseInt(newPrice), referrer, { from: address, value: parseInt(price + tax) })
    // } catch (err) {
    //   console.log('err', err)
    // }
    const transactionHash = await method.sendTransaction(
      parseInt(id),
      parseInt(newPrice),
      referrer,
      { from: address, value: parseInt(price + tax), gas }
    )
    return transactionHash ? true : false
  }

  async getTax(value) {
    const tax = await this.instance._priceToTax(value)
    return tax.toNumber()
  }

  async setTilePrice({ address, id, newPrice, referrer }) {
    const tax = await this.getTax(newPrice) + 1
    const transactionHash = await this.instance.setTilePrice.sendTransaction(
      parseInt(id),
      parseInt(newPrice),
      referrer,
      { from: address, value: tax, gas: GAS_LIMIT }
    )
    return transactionHash ? true : false
  }
}

export const instantiateContract = async (contract) => {
  const instance = await contract.deployed()
  return new Contract(instance)
}
