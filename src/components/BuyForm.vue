<template>
  <SectionShell>
    <template v-if="selectedTile.id >= 0">
      <div class="row">
        <h1>World {{ selectedTile.id }}</h1>
        <p class="owner" v-if="selectedTile.owner == address">You own this world</p>
        <p class="owner" v-else-if="selectedTile.owner">{{ selectedTile.owner | hashShorten }} owns this world</p>
        <p class="owner" v-else>Nobody owns this world</p>
      </div>
      <div class="price"><p>Ξ{{ selectedTile.price | weiToEth }}</p></div>
      <h2 class="label" v-if="canBuyOrChangePrice">Set your listing price (don't leave this empty!)</h2>
      <div v-if="canBuyOrChangePrice" class="buy-tile-container">
        <span class="price-input"><small>Ξ</small>
          <input v-model="newPrice" placeholder="Set a price" type="number" @input="updateTotal"/>
        </span>
        <button v-if="selectedTile.owner === address" class="button" @click.prevent="handleChangePrice">Change Price</button>
        <button v-else class="button" @click.prevent="handleBuyTile">Buy World {{ selectedTile.id }}</button>
      </div>
      <ul v-if="canBuyOrChangePrice" class="tax-container">
        <li><span>Price</span>
          <span v-if="selectedTile.owner == address">&mdash;</span>
          <span v-else-if="selectedTile.owner || roundNumber == 0">Ξ{{ selectedTile.price | weiToEth }}</span>
        </li>
        <li><span>Tax</span><span>Ξ{{ tax | weiToEth }}</span></li>
        <hr>
        <li><span>Total</span>
          <strong v-if="selectedTile.owner == address">Ξ{{ tax | weiToEth }}</strong>
          <strong v-else-if="selectedTile.owner || roundNumber == 0">Ξ{{ total | weiToEth }}</strong>
        </li>
      </ul>
    </template>
    <template v-else-if="status">
      <h1>Tell your friends your microverse world is on sale for Ξ{{ newPrice }}</h1>
      <SocialShare :tweet="tweet" />
    </template>
  </SectionShell>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
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
      tax: 0,
      total: 0,
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'domain', 'roundNumber']),

    newPriceInWei() {
      return this.$options.filters.ethToWei(this.newPrice)
    },
    tweet() {
      return status == 'tileBought'
        ? `I just bought a tile in Microverse ${this.domain}`
        : `My microverse world is on sale for ${this.newPrice} eth at ${this.domain}`
    },
    canBuyOrChangePrice() {
      return this.contract && this.roundNumber != 0 || !this.selectedTile.owner
    },
    price() {
      return this.selectedTile.price
    },
  },
  methods: {
    ...mapActions(['deselectTile']),
    ...mapMutations(['SHOW_MESSAGE']),

    async handleBuyTile() {
      // Don't allow 0-priced tile!
      if (this.newPrice === null || this.newPrice == 0) {
        alert('Please set a nonzero listing price!')
        return
      }

      let success = false
      const id = this.selectedTile.id
      this.SHOW_MESSAGE({ text: 'Check your wallet provider to complete buying this world.' })
      try {
        success = await this.contract.buyTile(
          {
            address: this.address,
            id,
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
    async updateTotal() {
      await this.updateTax()
      this.total = this.tax + this.selectedTile.price
    },
    async updateTax() {
      if (!this.contract) return
      try {
        const newPrice = this.$options.filters.ethToWei(this.newPrice)
        const tax = await this.contract.getTax(newPrice)
        this.tax = tax
      } catch (err) {
        console.log('err', err)
      }
    },
    async handleChangePrice() {
      let success = false
      const id = this.selectedTile.id
      this.SHOW_MESSAGE({ text: 'Check your wallet provider to complete changing this world\'s price.' })
      try {
        success = await this.contract.setTilePrice(
          {
            address: this.address,
            id,
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
  },
  watch: {
    price: ['updateTotal']
  }
}
</script>

<style scoped>
.buy-tile-container {
  display: flex;
}
.buy-tile-container input {
  border: 1px solid #222;
  width: 15em;
}
.buy-tile-container button {
  background: green;
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
ul {
  padding-left: 0;
  list-style-type: none;
}
ul li {
  display: flex;
  padding: 2px;
  align-items: center;
}
ul span {
  width: 90px
}
strong {
  font-weight: 600
}
.highlight {
  background: #bababa;
  padding: 0 2px;
}
.tax-container hr {
  width: 16rem;
  margin-left: 0;
}

.tax-container {
  padding-top: 1rem;
}

.row {
  display: flex;
  flex-direction: row;
}

.owner {
  margin-top: .6rem;
  margin-left: auto;
  color: grey;
}

.price {
  font-size: 1.2rem;
}
@media only screen and (max-width: 768px) {
  .row {
    flex-direction: column;
  }
  .owner {
    margin-left: 0;
  }
  .buy-tile-container {
    flex-direction: column;
  }
}
</style>


