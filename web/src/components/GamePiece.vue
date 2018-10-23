<template>
  <svg id="game-piece" xmlns="http://www.w3.org/2000/svg" version="1.1" :width="width" :height="height" xmlns:xlink="http://www.w3.org/1999/xlink">
    <polygon class="hex" :points="points"></polygon>
    <slot></slot>
  </svg>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'GamePiece',
  data() {
    return {
      width: 100,
      height: 80,
    }
  },
  computed: {
    points() {
      const w = this.width
      const h = this.height
      // https://www.redblobgames.com/grids/hexagons/
      return `0,${0.25*h} ${0.5*w},0 ${w},${0.25*h} ${w},${0.75*h} ${0.5*w},${h} 0,${0.75*h}`
    },
  },
  methods: {
  },
  mounted() {
  },
}
</script>

<style scoped>
.hex {
  fill-opacity: 0.4;
  stroke: #000;
  stroke-width: 1;
}

#game-piece .hex {
  fill: #ffff00;
}

#game-piece:hover .hex {
  fill: #ffff99;
}

#game-piece {
  cursor: pointer;
}
</style>
