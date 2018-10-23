<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #001</h1>
      <p>Microverse is a simulation. Acquire worlds and power them up to earn a slice of Microverse trade. When trade slows, the simulation stops and riches are airdropped to the least powerful worlds. And the simulation starts over.</p>
    </div>
    <div class="section section-accent">
      <p class="label">Simulation #001</p>
      <p><b>Stimulus (jackpot):</b> Ξ203.55 ($10000)</p>
      <p><b>Time left:</b> {{ timeLeft }} seconds</p>
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
          <div @click.prevent="getTileDetails(tileId)" v-for="tileId in tileIdRow"
               :key="tileId">
            <GamePiece :buyable="tileIsBuyable(tileId)">
              <text 
                v-if="contractInstance && contractInstance.tilesLoaded" 
                x="50%" y="50%" 
                alignment-baseline="middle" 
                text-anchor="middle">
                Ξ{{ contractInstance.tiles[tileId].price | weiToEth }}
              </text>
            </GamePiece>
          </div>
        </div>
      </div>
    </div>
    <div v-if="selectedTile.id >= 0" class="section tile-information">
      <h1>Tile {{ selectedTile.id }}</h1>
      Ξ{{ selectedTile.price | weiToEth }}
      {{ selectedTile.owner }}
      <template v-if="contractInstance.gameStage == 1 || !selectedTile.owner">
        <input v-model="newPrice" placeholder="Enter the new price" type="number"/>
        <button @click.prevent="contractInstance.buyTile({ address, id: selectedTile.id, newPrice })">Buy</button>
      </template>
    </div>
  </div>
</template>

<script>
import GamePiece from './GamePiece'
import { mapGetters } from 'vuex'
import { instantiateContract } from './contract'
import MicroverseConfig from '@/Microverse.json'
import contract from 'truffle-contract'
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
      },
    }
  },
  computed: {
    ...mapGetters(['address', 'network']),
    wrongNetwork() {
      // TODO: Turn this check back on for prod
      // return this.network != this.NETWORK_ID
      return false
    },
  },
  methods: {
    tileIsBuyable(id) {
      if (!this.contractInstance || !this.contractInstance.tilesLoaded) return false
      return this.contractInstance.tiles[id].buyable
    },
    async getTileDetails(id) {
      if (!this.contractInstance) return
      const price = await this.contractInstance.getTilePrice(id)
      const owner = await this.contractInstance.tileToOwner(id)
      this.selectedTile = {
        id,
        price,
        owner
      }
    },
    async initializeCountDown() {
      const timeLeft = await this.contractInstance.getTimeRemaining()
      this.timeLeft = timeLeft
      this.timer(timeLeft)
    },
    timer(timeLeft) {
      // https://stackoverflow.com/questions/29971898/how-to-create-an-accurate-timer-in-javascript
      const interval = 1000; // ms
      let expected = Date.now() + interval;
      const that = this
      setTimeout(step, interval);
      function step() {
          const dt = Date.now() - expected; // the drift (positive for overshooting)
          if (dt > interval) {
              // something really bad happened. Maybe the browser (tab) was inactive?
              // possibly special handling to avoid futile "catch up" run
          }
          expected += interval;
          that.timeLeft -= interval / 1000
          setTimeout(step, Math.max(0, interval - dt)); // take into account drift
      }
    }
  },
  mounted() {
    if (!window.web3) return
    const abstractContract = contract(MicroverseConfig)
    abstractContract.setProvider(window.web3.currentProvider)
    instantiateContract(abstractContract).then(instance => {
      this.contractInstance = instance
      this.initializeCountDown()
    })
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
