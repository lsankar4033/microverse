<template>
  <svg id="color-fill" xmlns="http://www.w3.org/2000/svg" version="1.1" :width="width" :height="height" xmlns:xlink="http://www.w3.org/1999/xlink">
    <polygon @click.prevent="openModal" class="hex" :points="points"></polygon>
  </svg>
</template>

<script>
export default {
  name: 'GamePiece',
  props: ['owned', 'value'],
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
    openModal() {
      console.log('hi')
    },
  }
}
</script>

<style scoped>
/* https://codepen.io/cwmanning/pen/Hugye */
.hex {
  cursor: pointer;
  fill-opacity: 0.4;
  stroke: #000;
  stroke-width: 1;
}

#color-fill .hex {
  fill: #ffff00;
}
</style>
