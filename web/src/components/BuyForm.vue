<template>
  <SectionShell>
    <h1>World {{ tile.id }}</h1>
    <div class="tile-information">
      <span>Ξ{{ tile.price | weiToEth }}</span>
      <span>{{ tile.owner }}</span>
    </div>
    <div class="buy-tile-container" v-if="contract && contract.gameStage == 1 || !tile.owner">
      <input v-model="newPrice" placeholder="Enter the new price" type="number"/>
      <button v-if="tile.owner === address" class="button" @click.prevent="handleChangePrice">Buy</button>
      <button v-else class="button" @click.prevent="handleBuyTile">Buy</button>
    </div>
    <SocialIcon type="facebook" />
    <SocialIcon type="twitter" />
    <SocialIcon type="mail" />
  </SectionShell>
</template>

<script>
import { mapGetters } from 'vuex'
import SectionShell from './SectionShell'
import SocialIcon from './SocialIcon'

export default {
  name: 'BuyForm',
  props: ['contract'],
  components: {
    SectionShell,
    SocialIcon
  },
  data() {
    return {
      newPrice: null,
    }
  },
  computed: {
    ...mapGetters(['address', 'tile']),
  },
  methods: {
    async handleBuyTile() {
      let success = false
      try {
        success = await this.contract.buyTile({ address: this.address, id: this.tile.id, newPrice: this.newPrice })
      } catch (err) {
        console.log('err', err)
      }
      // TODO: Add social sharing link on success.
      console.log('success', success)
    },
    async handleChangePrice() {
      console.log('TODO')
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


