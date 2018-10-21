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
      <template v-if="!address || network != '1'">
        <div class="overlay" />
        <div class="no-wallet-text">
          <h1 v-if="!address">Log into <a target="_blank" href="https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en">metamask</a> or another browser wallet extension to play</h1>
          <h1 v-if="address && !network != '1'">Make sure mainnet network is selected</h1>
        </div>
      </template>
      <p class="label">Click to acquire a world</p>
      <div class="grid">
        <div v-for="tileIdRow in tileIdRows" class="row">
          <div v-for="tileId in tileIdRow">
            <GamePiece :id="tileId" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import GamePiece from './GamePiece'
import { mapGetters } from 'vuex'

// Width of top row of hex board.
// TODO: Move to 'utils' file
const BoardWidth =  3

export default{
  name: 'GameBoard',
  components: {
    GamePiece,
  },
  data() {
    return {
      tileIdRows: this.generateTileIds(BoardWidth)
    }
  },
  methods: {
    getId(row, col) {
      return `${row}, ${col}`
    },
    generateTileIds(width) {
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
  },
  computed: {
    ...mapGetters(['address', 'network'])
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
