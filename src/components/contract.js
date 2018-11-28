// TODO: Scrape from ethgasstation
const defaultGasPrice = 7000000000 // 7 gwei

function getGasLimit(gasEstimate) {
  return gasEstimate * 5
}

// Utility for creating a promise around a delay
const delay = t => new Promise(resolve => setTimeout(resolve, t));

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

async function withRetries(query, { nullValue, maxRetries = null, retryDelayMs = 1000 }) {
  let result = await query()

  if (result == nullValue && (maxRetries === null || maxRetries > 0)) {
    await delay(retryDelayMs)

    let newMaxRetries = maxRetries === null ? null : maxRetries - 1
    let result = await withRetries(
      query,
      { nullValue: nullValue, maxRetries: newMaxRetries, retryDelayMs: retryDelayMs }
    )

    return result
  } else {
    // NOTE: We may want to do something different if failed getting a good value after retries
    return result
  }
}

class Contract {
  constructor(contractInstance) {
    this.instance = contractInstance
  }

  async getTile(id, { auctionPrice, roundNumber }) {
    const owner = await withRetries(async () =>
      {
        const owner = await this.tileToOwner(id)
        return owner
      },
      { nullValue: '0x' }
    )

    let price = 0
    if (roundNumber === 0 && !owner) {
      price = auctionPrice
    } else {
      price = await withRetries(async () =>
        {
          const price = this.tileToPrice(id)
          return price
        },
        { nullValue: 0 }
      )
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
    const payment = await withRetries(async () =>
      {
        const p = await this.instance.payments(address)
        return p.toNumber()
      },
      { nullValue: 0 }
    )
    return payment
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

  async getRoundEndTime() {
    const endTime = await withRetries(async () =>
      {
        const e = await this.instance.roundEndTime()
        return e.toNumber()
      },
      { nullValue: 0 }
    )
    return endTime
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

    const end = await this.getRoundEndTime()
    const now = + new Date() / 1000
    return end - now
  }

  async getCurrentRoundExtension() {
    const extension = await this.instance.curRoundExtension()
    // returns number in seconds
    return extension.toNumber()
  }

  async getTilePriceAuction() {
    const price = await this.instance.getTilePriceAuction()
    return price.toNumber()
  }

  async tileToPrice(id, maxRetries = 10, retryDelayMs = 1000) {
    const price = await this.instance.tileToPrice(id)
    return price.toNumber()
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
