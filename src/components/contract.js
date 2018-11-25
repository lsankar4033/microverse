// TODO: Scrape from ethgasstation
const defaultGasPrice = 7000000000 // 7 gwei

function getGasLimit(gasEstimate) {
  return gasEstimate * 5
}

async function callContractMethod(method, args, msg) {
  let estimationArgs = args.slice(0)
  estimationArgs.push(msg)
  let gasEstimate = await method.estimateGas(...estimationArgs)

  const actualMsg = {
    ...msg,
    gas: getGasLimit(gasEstimate),
    gasPrice: defaultGasPrice,
  };
  const actualArgs = args.slice(0)
  actualArgs.push(actualMsg)

  let txHash = await method.sendTransaction(...actualArgs)
  return txHash
}

class Contract {
  constructor(contractInstance) {
    this.instance = contractInstance
  }

  async getTile(id, { auctionPrice, roundNumber }) {
    const owner = await this.tileToOwner(id)

    let price = 0
    if (roundNumber === 0 && !owner) {
      price = auctionPrice
    } else {
      price = await this.tileToPrice(id)
    }

    // Tiles only not buyable if already bought in auction phase
    let buyable
    if (roundNumber === 0) {
      buyable = owner ? false : true
    } else {
      buyable = true
    }

    const loaded = true
    const tile = { owner, price, buyable, loaded, id }

    return tile
  }

  async getJackpot() {
    const jackpot = await this.instance.jackpot()
    return jackpot.toNumber()
  }

  async getNextJackpot() {
    const nextJackpot = await this.instance.nextJackpot()
    return nextJackpot.toNumber()
  }

  async endGameRound(address) {
    await this.instance.endGameRound({ from: address })
  }

  async getBalance(address) {
    const payment = await this.instance.payments(address)
    return payment.toNumber()
  }

  async withdraw(address) {
    const transactionHash = await callContractMethod(
      this.instance.withdrawPayments,
      [],
      { from: address }
    )

    return transactionHash ? true : false
  }

  async stage() {
    const s = await this.instance.stage()
    return s.toNumber()
  }

  async roundNumber() {
    const r = await this.instance.roundNumber()
    return r.toNumber()
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

  async tileToOwner(id) {
    const owner = await this.instance.tileToOwner(id)
    const nullAddresses = ['0x0000000000000000000000000000000000000000', '0x']
    
    if (nullAddresses.includes(owner)) return null

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

  async buyTile({ address, id, newPrice, referrer }) {
    const stage = await this.stage()
    let price
    let method
    let tax = 0
    let transactionHash = null
    if (stage === 0) {
      price = await this.getTilePriceAuction()
      // TODO: Do we need to charge tax here?
      tax = await this.getTax(newPrice)
      method = this.instance.buyTileAuction

      transactionHash = await callContractMethod(
        method,
        [parseInt(id), parseInt(newPrice), referrer],
        { from: address, value: parseInt(price + tax) }
      )
    } else {
      price = await this.tileToPrice(id)
      tax = await this.getTax(newPrice) + 1
      method = this.instance.buyTile

      transactionHash = await callContractMethod(
        method,
        [parseInt(id), parseInt(newPrice), referrer],
        { from: address, value: parseInt(price + tax) }
      )
    }
    return transactionHash ? true : false
  }

  async getTax(value) {
    const tax = await this.instance._priceToTax(value)
    return tax.toNumber()
  }

  async setTilePrice({ address, id, newPrice, referrer }) {
    const tax = await this.getTax(newPrice) + 1

    const transactionHash = await callContractMethod(
      this.instance.setTilePrice,
      [parseInt(id), parseInt(newPrice), referrer],
      { from: address, value: parseInt(tax) }
    )

    return transactionHash ? true : false
  }
}

export const instantiateContract = async (contract) => {
  const instance = await contract.deployed()
  return new Contract(instance)
}
