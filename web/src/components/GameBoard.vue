<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #001</h1>
      <p>Microverse is a simulation. Acquire worlds and power them up to earn a slice of Microverse trade. When trade slows, the simulation stops and riches are airdropped to the least powerful worlds. And the simulation starts over.</p>
    </div>
    <div class="section section-accent">
      <p class="label">Simulation #001</p>
      <p><b>Stimulus (jackpot):</b> Ξ203.55 ($10000)</p>
      <p><b>Time left:</b> 11h 33m 22s</p>
    </div>
    <div class="section section-body">
      <template v-if="!address || wrongNetwork">
        <div class="overlay" />
        <div class="no-wallet-text">
          <h1 v-if="!address">Log into <a target="_blank" href="https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en">metamask</a> or another browser wallet extension to play</h1>
          <h1 v-if="address && wrongNetwork">Make sure mainnet network is selected</h1>
        </div>
      </template>
      <p class="label">Click to acquire a world</p>
      <div class="grid">
        <div v-for="(tileIdRow, rowIdx) in tileIdRows"
             :key="rowIdx"
             class="row">
          <div v-for="tileId in tileIdRow"
               :key="tileId">
            <GamePiece :id="tileId" />
          </div>
        </div>
      </div>
    </div>
    <div v-if="selectedTile.id >= 0" class="section tile-information">
      <h1>Tile {{ selectedTile.id }}</h1>
      Ξ{{ selectedTile.price }}
      {{ selectedTile.owner }}
      <template v-if="gameState !== 0 || !selectedTile.owner">
        <input v-model="newPrice" placeholder="Enter the new price" type="number"/>
        <button @click.prevent="buyTile({ id: selectedTile.id, newPrice })">Buy</button>
      </template>
    </div>
  </div>
</template>

<script>
import GamePiece from './GamePiece'
import { mapGetters, mapActions } from 'vuex'

// Width of top row of hex board.
// TODO: Move to 'utils' file
const BoardWidth =  3

const generateTileIds = width => {
  var curId = 1
  let rows = []

  // Increasing rows
  var curRowSize = width
  for (var i = 0; i < width; i++) {
    let row = []
    for (var j = 0; j < curRowSize; j++) {
      row.push(curId)
      curId++;
    }

    rows.push(row)
    curRowSize++;
  }

  // Decreasing rows
  curRowSize--;
  curRowSize--;
  for (i = 0; i < (width-1); i++) {
    let row = []
    for (j = 0; j < curRowSize; j++) {
      row.push(curId)
      curId++;
    }

    rows.push(row)
    curRowSize--;
  }

  return rows;
}

const tileIdRows = generateTileIds(BoardWidth)

export default{
  name: 'GameBoard',
  components: {
    GamePiece,
  },
  data() {
    return {
      tileIdRows,
      NETWORK_ID: '1540158046332',
      contractInstance: null,
      timeLeft: 'Loading',
      newPrice: null,
      selectedTile: {
        id: -1,
        price: 0,
        owner: null,
      }
    }
  },
  computed: {
    ...mapGetters(['address', 'network', 'contract', 'tile', 'gameState']),
    wrongNetwork() {
      // TODO: Turn this check back on for prod
      // return this.network != this.NETWORK_ID
      return false
    },
  },
  methods: {
    ...mapActions(['setTiles', 'buyTile']),

    async stage() {
      if (!this.contractInstance) return
      const x = await this.contractInstance.stage()
      return x.toNumber()
    },
    async auctionDuration() {
      if (!this.contractInstance) return
      const x = await this.contractInstance.auctionDuration()
      return x.toNumber()
    },
    setTileDetails() {
      const query = this.$route.query
      if (!query) return
      const id = query.tile
      this.selectedTile.id = id
      const tile = this.tile(id)
      if (!tile) return
      this.selectedTile.price = tile.price
      this.selectedTile.owner = tile.owner
    },
  },
  watch: {
    contract: async function() {
      if (!this.contract) return
      const instance = await this.contract.deployed()
      this.contractInstance = instance
      const events = instance.allEvents({ fromBlock: 0, toBlock: 'latest' })
      events.watch((err, e) => {
        if (err) return
        if (e.event === 'AuctionStarted') {
          const start = e.args.startTime.toNumber()
          const duration = e.args.auctionDuration.toNumber()
          const end = this.$moment.unix(start + duration)
          // TODO: Calculate remaining time from the end time
          console.log('end time', end.format('MM/DD/YYYY HH:MM:SS'))
        }
      })
      const stage = await instance.stage()
      this.$store.commit('UPDATE_STATE', { key: 'gameState', value: stage.toNumber() })
      this.setTiles({ rows: this.tileIdRows, priceMapping: instance.tileToPrice, ownerMapping: instance.tileToOwner })
    },
    '$route.query': async function() {
      this.setTileDetails()
    }
  },
}
</script>

<style scoped>
.section-body {
  position: relative;
  padding: 0;
}
.overlay {
  position: absolute;
  height: 100%;
  width: 100%;
  opacity: 0.8;
  background: #fff;
}
.no-wallet-text {
  position: absolute;
  height: 100%;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
}
.no-wallet-text h1 {
  margin: auto;
  text-align: center;
}
</style>
