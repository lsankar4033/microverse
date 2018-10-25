<template>
  <SectionShell>
    <template v-if="tile.id >= 0">
      <h1>World {{ tile.id }}</h1>
      <div class="tile-information">
        <div>Ξ{{ tile.price | weiToEth }}</div>
        <h2 v-if="tile.owner == address">You own this world</h2>
        <h2 v-else-if="tile.owner">{{ tile.owner }} owns this world</h2>
        <h2 v-else>Nobody owns this world</h2>
      </div>
      <div class="buy-tile-container" v-if="contract && contract.gameStage == 1 || !tile.owner">
        <input v-model="newPrice" placeholder="Enter the new price" type="number"/>
        <button v-if="tile.owner === address" class="button" @click.prevent="handleChangePrice">Change Price</button>
        <button v-else class="button" @click.prevent="handleBuyTile">Buy</button>
      </div>
    </template>
    <template v-else-if="status">
      <h1 v-if="status == 'tileBought'">Tell your friends you own a microverse world</h1>
      <h1 v-if="status == 'priceChanged'">Tell your friends your microverse world is on sale for Ξ{{ newPrice }}</h1>
      <SocialShare />
    </template>
  </SectionShell>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import SectionShell from './SectionShell'
import SocialShare from './SocialShare'

export default {
  name: 'BuyForm',
  props: ['contract'],
  components: {
    SectionShell,
    SocialShare
  },
  data() {
    return {
      newPrice: null,
      // tileBought, priceChanged
      status: '',
    }
  },
  computed: {
    ...mapGetters(['address', 'tile']),
  },
  methods: {
    ...mapActions(['deselectTile']),

    async handleBuyTile() {
      let success = false
      try {
        success = await this.contract.buyTile({ address: this.address, id: this.tile.id, newPrice: this.newPrice })
      } catch (err) {
        console.log('err', err)
      }
      // TODO: Add social sharing link on success.
      if (!success) return
      this.deselectTile()
      this.status = 'tileBought'
    },
    async handleChangePrice() {
      let success = false
      try {
        success = await this.contract.setTilePrice({ address: this.address, id: this.tile.id, newPrice: this.newPrice })
      } catch (err) {
        console.log('err', err)
      }
      if (!success) return
      this.deselectTile()
      this.status = 'priceChanged'
    },
  }
}
</script>

<style>
.buy-tile-container {
  display: flex;
  margin-bottom: 26px;
}
.buy-tile-container input {
  border: 1px solid #222;
}
.buy-tile-container button {
  background: green;
}
.tile-information {
  margin: 8px 0 10px;
  font-size: 16pt;
}
</style>


