<template>
  <svg class="game-piece" xmlns="http://www.w3.org/2000/svg" version="1.1" :width="width" :height="height" xmlns:xlink="http://www.w3.org/1999/xlink">
    <polygon
      :class="{
        hex: true,
        buyable,
        'owned-by-user': ownedByUser,
        selected: selectedTile.id == id
      }"
      :points="points" />
    <text 
      v-if="tile(id)" 
      x="50%" y="50%" 
      alignment-baseline="middle" 
      text-anchor="middle">
      Ξ{{ tile(id).price | weiToEth | setPrecision(4) }}
    </text>
  </svg>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'GamePiece',
  props: ['id', 'contract'],
  data() {
    return {
      width: 100,
      height: 80,
      ownedByUser: false,
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'tile']),
    buyable() {
      const tile = this.tile(this.id)
      if (!tile) return false
      return tile.buyable
    },
    owner() {
      const tile = this.tile(this.id)
      if (!tile) return false
      return tile.owner
    },
    points() {
      const w = this.width
      const h = this.height
      // https://www.redblobgames.com/grids/hexagons/
      return `0,${0.25*h} ${0.5*w},0 ${w},${0.25*h} ${w},${0.75*h} ${0.5*w},${h} 0,${0.75*h}`
    },
  },
  methods: {
    async setOwnedByUser(tileId) {
      if (!this.contract) return
      const owner = await this.contract.tileToOwner(tileId)
      this.ownedByUser = owner == this.address
    }
  },
  mounted() {
    // TODO: Use a window listener -- breaks if user resizes screen w/o refresh
    if (screen.width < 768 || window.innerWidth < 768) {
      this.width = 60
      this.height = 40
    }
    // Hacky fix to issue where owner on mount isn't set
    const tile = this.tile(this.id)
    if (!tile) return
    this.ownedByUser = tile.owner == this.address
  },
  watch: {
    // TODO: Optimization, come up with solution that doesn't require a watcher.
    owner() {
      if (this.id) this.setOwnedByUser(this.id)
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
