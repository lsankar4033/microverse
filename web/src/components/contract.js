// EVENTS
// const events = instance.allEvents({ fromBlock: 0, toBlock: 'latest' })
// events.watch((err, e) => {
//   if (err) return
//   if (e.event === 'AuctionStarted') {
//     const start = e.args.startTime.toNumber()
//     const duration = e.args.auctionDuration.toNumber()
//     const end = this.$moment.unix(start + duration)
//     // TODO: Calculate remaining time from the end time
//     console.log('end time', end.format('MM/DD/YYYY HH:MM:SS'))
//   }
// })

class Contract {
  constructor(contractInstance) {
    this.instance = contractInstance
    this.tiles = {}
    this.tilesLoaded = false
    this.gameStage = null
    this.update()
  }

  async update() {
    await this.setTiles()
    this.tilesLoaded = true
    this.gameStage = await this.stage()
  }

  async stage() {
    const s = await this.instance.stage()
    return s.toNumber()
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

  async setTiles() {
    const minId = await this.minTileId()
    const maxId = await this.maxTileId()
    for(let id = minId; id <= maxId; id++) {
      const owner = await this.tileToOwner(id)
      const price = await this.getTilePrice(id)
      this.tiles[id] = { owner, price }
    }
  }

  async buyTile({ address, id, newPrice }) {
    const stage = await this.stage()
    let price
    let method
    if (stage === 0) {
      price = await this.getTilePriceAuction()
      method = this.instance.buyTileAuction
    } else {
      price = await this.tileToPrice(id)
      method = this.instance.buyTile
    }
    method.sendTransaction(parseInt(id), parseInt(newPrice), { from: address, value: price, gas: 3000000})
  }
}

export const instantiateContract = async (contract) => {
  const instance = await contract.deployed()
  return new Contract(instance)
}