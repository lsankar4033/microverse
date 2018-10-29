<template>
  <SectionShell>
    <template v-if="selectedTile.id >= 0">
      <h1>World {{ selectedTile.id }}</h1>
      <div class="tile-information">
        <div>Ξ{{ selectedTile.price | weiToEth }}</div>
        <h2 v-if="selectedTile.owner == address">You own this world</h2>
        <h2 v-else-if="selectedTile.owner">{{ selectedTile.owner | hashShorten }} owns this world</h2>
        <h2 v-else>Nobody owns this world</h2>
      </div>
      <div class="buy-tile-container" v-if="contract && contract.gameStage == 1 || !selectedTile.owner">
        <span class="price-input"><small>Ξ</small>
          <input v-model="newPrice" placeholder="Enter the new price" type="number"/>
        </span>
        <button v-if="selectedTile.owner === address" class="button" @click.prevent="handleChangePrice">Change Price</button>
        <button v-else class="button" @click.prevent="handleBuyTile">Buy</button>
      </div>
    </template>
    <template v-else-if="status">
      <h1>Tell your friends your microverse world is on sale for Ξ{{ newPrice }}</h1>
      <SocialShare :tweet="tweet" />
    </template>
  </SectionShell>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import SectionShell from './SectionShell'
import SocialShare from './SocialShare'

export default {
  name: 'BuyForm',
  props: ['contract', 'referrer'],
  components: {
    SectionShell,
    SocialShare
  },
  data() {
    return {
      newPrice: null,
      // tileBought or priceChanged
      status: '',
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'domain']),

    newPriceInWei() {
      return this.$options.filters.ethToWei(this.newPrice)
    },
    tweet() {
      return status == 'tileBought'
        ? `I just bought a tile in Microverse ${this.domain}`
        : `My microverse world is on sale for ${this.newPrice} eth at ${this.domain}`
    },
  },
  methods: {
    ...mapActions(['deselectTile']),

    async handleBuyTile() {
      let success = false

      try {
        success = await this.contract.buyTile(
          {
            address: this.address,
            id: this.selectedTile.id,
            newPrice: this.newPriceInWei,
            referrer: this.referrer 
          })
      } catch (err) {
        console.log('err', err)
      }
      if (!success) return
      this.deselectTile()
      this.status = 'tileBought'
    },
    async handleChangePrice() {
      let success = false
      try {
        success = await this.contract.setTilePrice(
          {
            address: this.address,
            id: this.selectedTile.id,
            newPrice: this.newPriceInWei,
            referrer: this.referrer
          })
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
.price-input {
  border: 1px inset #ccc;
}
.price-input small {
  padding: 0 4px;
}
.price-input input {
  border: 0;
}
</style>


