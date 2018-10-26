const GAS_LIMIT = 3000000

class Contract {
  constructor(contractInstance, events) {
    this.instance = contractInstance
    this.tiles = {}
    this.tilesLoaded = false
    this.gameStage = null
    this.jackpot = null
    this.events = events
    this.update()
  }

  async update() {
    await this.setTiles()
    this.tilesLoaded = true
    this.gameStage = await this.stage()
    this.jackpot = await this.getJackpot()
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

  //async setTilePrice({ address, id, newPrice }) {
    //// TODO: test this
    //const owner = await this.tileToOwner(id)
    //if (owner !== address) return false
    //const transactionHash =
      //this.instance.sendTransaction(parseInt(id), parseInt(newPrice), { from: address, value: parseInt(newPrice), gas: GAS_LIMIT})
    //if (transactionHash) return true
    //return false
  //}

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

  async setTiles() {
    const minId = await this.minTileId()
    const maxId = await this.maxTileId()
    for(let id = minId; id <= maxId; id++) {
      const owner = await this.tileToOwner(id)
      const price = await this.getTilePrice(id)
      const buyable = await this.tileIsBuyable(id)
      this.tiles[id] = { owner, price, buyable }
    }
  }

  async tileIsBuyable(id) {
    const stage = await this.stage()
    const owner = await this.tileToOwner(id)
    if (stage === 0 && owner) return false
    return true
  }

  async buyTile({ address, id, newPrice }) {
    const stage = await this.stage()
    let price
    let method
    if (stage === 0) {
      price = await this.getTilePriceAuction()
      // TODO: Investigate if we need to charge tax here?
      price += await this.getTax(newPrice)
      method = this.instance.buyTileAuction
    } else {
      // TODO: Check if we need to use setTilePrice if this is the owner
      price = await this.tileToPrice(id)
      price += await this.getTax(newPrice)
      // price += Math.ceil(newPrice / 10)
      method = this.instance.buyTile
    }
    const transactionHash = await method.sendTransaction(parseInt(id), parseInt(newPrice), { from: address, value: parseInt(price), gas: GAS_LIMIT })
    if (transactionHash) return true
    return false
  }

  async getTax(value) {
    // TODO: pull tax constant from contract
    const tax = await this.instance._priceToTax(value)
    return tax.toNumber()
  }

  async setTilePrice({ address, id, newPrice }) {
    // const tax = Math.ceil(newPrice / 10)
    const tax = await this.getTax(newPrice) + 1
    const transactionHash = await this.instance.setTilePrice.sendTransaction(parseInt(id), parseInt(newPrice), { from: address, value: tax, gas: GAS_LIMIT })
    return transactionHash ? true : false
  }
}

export const instantiateContract = async (contract) => {
  const instance = await contract.deployed()
  const events = instance.allEvents({ fromBlock: 0, toBlock: 'latest' })
  return new Contract(instance, events)
}
