<template>
  <main>
    <section @click="deselectTile">
      <div v-for="(tileIdRow, rowIdx) in tileIdRows"
            :key="rowIdx"
            class="row">
        <div @click.stop.prevent="selectTile(tileId)" v-for="tileId in tileIdRow"
              :key="tileId">
          <GamePiece :id="tileId" :contract="contract"></GamePiece>
        </div>
      </div>
    </section>
  </main>
</template>

<script>
import SectionShell from './SectionShell'
import { mapGetters, mapActions, mapMutations } from 'vuex'
import GamePiece from './GamePiece'

// Width of top row of hex board.
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
  props: ['contract', 'timeLeft'],
  components: {
    GamePiece,
    SectionShell,
  },
  data() {
    return {
      tileIdRows,
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'network', 'message', 'roundNumber', 'tile']),
    wrongNetwork() {
      if (this.network == '1' || this.network == '3' || this.network == '5777') return false
      return true
    },
  },
  methods: {
    ...mapActions(['deselectTile', 'setTile']),
    ...mapMutations(['HIDE_MESSAGE']),

    setSelectedTile(tile) {
      this.$store.commit('UPDATE_STATE', { key: 'selectedTile', value: tile })
    },
    async selectTile(id) {
      const tile = this.tile(id)
      if (tile) {
        this.setSelectedTile(tile)
      }
    },
    async endRound() {
      await this.contract.endGameRound(this.address)
    },
  },
}
</script>

<style scoped>
section {
  display: flex;
  flex-direction: column;
  align-items: center;
  margin-bottom: 50px;
}
.row {
  display: flex;
  margin-bottom: -1.5rem;
}
</style>

