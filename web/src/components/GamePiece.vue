<template>
  <svg class="game-piece" xmlns="http://www.w3.org/2000/svg" version="1.1" :width="width" :height="height" xmlns:xlink="http://www.w3.org/1999/xlink">
    <polygon :class="{hex: true, buyable, 'owned-by-user': ownedByUser, selected: tile.id == id}" :points="points"></polygon>
    <slot></slot>
  </svg>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'GamePiece',
  props: ['id', 'buyable', 'ownedByUser'],
  data() {
    return {
      width: 100,
      height: 80,
    }
  },
  computed: {
    ...mapGetters(['address', 'tile']),

    points() {
      const w = this.width
      const h = this.height
      // https://www.redblobgames.com/grids/hexagons/
      return `0,${0.25*h} ${0.5*w},0 ${w},${0.25*h} ${w},${0.75*h} ${0.5*w},${h} 0,${0.75*h}`
    },
  },
  mounted() {
  // TODO: Use a window listener -- breaks if user resizes screen w/o refresh
    if (screen.width < 768 || window.innerWidth < 768) {
      this.width = 60
      this.height = 40
    }
  }
}
</script>

<style scoped>
.hex {
  fill-opacity: 0.4;
  stroke: #000;
  stroke-width: 1;
  fill: #888;
  cursor: pointer;
}

.buyable {
  fill: #ffff00;
}

.owned-by-user {
  fill: #fffff0;
}

.hex:hover {
  fill: #ffff99;
}

.selected {
  stroke: #005507;
  stroke-width: 5;
}

.game-piece text {
  cursor: pointer;
}
</style>
