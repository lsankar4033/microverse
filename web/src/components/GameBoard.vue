<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #001</h1>
      <p>Microverse is a simulation. Acquire worlds and power them up to earn a slice of Microverse trade. When trade slows, the simulation stops and a riches are airdropped to the worlds least powerful relative to their neighbors. And the simulation starts over.</p>
    </div>
    <div class="section section-accent">
      <p class="label">Simulation #001</p>
      <p><b>Stimulus (jackpot):</b> Ξ203.55 ($10000)</p>
      <p><b>Time left:</b> 11h 33m 22s</p>
    </div>
    <div class="section section-body">
      <p class="label">Click to acquire a world</p>
      <div class="grid">
        <div v-for="(row, colIdx) in board" class="row">
          <div v-for="(tile, rowIdx) in row">
            <GamePiece :id="getId(rowIdx, colIdx)" />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import GamePiece from './GamePiece'
export default{
  name: 'GameBoard',
  components: {
    GamePiece,
  },
  data() {
    return {
      board: [
        [{}, {}, {}],
        [{}, {}, {}, {}],
        [{}, {}, {}, {}, {}],
        [{}, {}, {}, {}],
        [{}, {}, {}],
      ]
    }
  },
  methods: {
    getId(row, col) {
      return `${row}, ${col}`
    }
  },
}
</script>
