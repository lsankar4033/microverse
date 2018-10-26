<template>
  <SectionShell class="board-container">
    <template v-if="!address || wrongNetwork">
        <div class="overlay" />
        <div class="no-wallet-text">
          <h1 v-if="!address">Log into <a target="_blank" href="https://chrome.google.com/webstore/detail/metamask/nkbihfbeogaeaoehlefnkodbefgpgknn?hl=en">metamask</a> or another browser wallet extension to play</h1>
          <h1 v-if="address && wrongNetwork">Make sure mainnet network is selected</h1>
        </div>
      </template>
      <p v-if="selectedTile.id < 0" class="label">Click to acquire a world</p>
      <p v-if="selectedTile.id >= 0" class="label">Viewing world {{ selectedTile.id }}</p>
      <div @click="deselectTile" class="grid">
        <div v-for="(tileIdRow, rowIdx) in tileIdRows"
             :key="rowIdx"
             class="row">
          <div @click.stop.prevent="selectTile(tileId)" v-for="tileId in tileIdRow"
               :key="tileId">
            <GamePiece :id="tileId">{{ setTile({id: tileId, contract}) }}</GamePiece>
          </div>
        </div>
      </div>
  </SectionShell>
</template>

<script>
import SectionShell from './SectionShell'
import { mapGetters, mapActions } from 'vuex'
import GamePiece from './GamePiece'

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

export default {
  name: 'Board',
  props: ['contract'],
  components: {
    GamePiece,
    SectionShell,
  },
  data() {
    return {
      tileIdRows,
      NETWORK_ID: "1",
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'network']),
    wrongNetwork() {
      // TODO: Turn this check back on for prod
      // return this.network != this.NETWORK_ID
      return false
    },
  },
  methods: {
    ...mapActions(['deselectTile', 'setTile']),

    setSelectedTile(tile) {
      this.$store.commit('UPDATE_STATE', { key: 'selectedTile', value: tile })
    },
    async selectTile(id) {
      const tile = await this.setTile({ id, contract: this.contract })
      this.setSelectedTile(tile)
    },
  },
}
</script>

<style>
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
.board-container {
  position: relative;
}
</style>

