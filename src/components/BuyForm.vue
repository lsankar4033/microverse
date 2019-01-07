<template>
  <main v-if="true">
    <header>
      <h1>World 17</h1>
      <h3>Owned by {{ '0xB5cef47fDcd96ae7f718DeD9a94030736F809C51' | hashShorten }}</h3>
    </header>
    <h2><EthSymbol/>4.34</h2>
    <form>
      <div>Set your listing price</div>
      <div>
        <span class="price-input">
          <EthSymbol class="input-unit" />
          <input type="number" placeholder="Enter a number less than 3.234">
          <button>Buy</button>
        </span>
        <ul class="error-list">
          <!-- Consider using v-html or custom component for errors so links work -->
          <li v-for="error in validationErrors">
            {{ error }}
          </li>
        </ul>
      </div>
      <ul class="price-summary">
        <li><label>Price</label><p>1.0</p></li>
        <li><label>Tax</label><p>0.2</p></li>
        <hr/>
        <li><label>Total</label><p><strong>1.2</strong></p></li>
      </ul>
    </form>
  </main>
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
      validationErrors: ['You must be logged into metamask', 'Price is too high'],
      newPrice: null,
      // tileBought or priceChanged
      status: '',
      tax: 0,
      total: 0,
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'domain', 'roundNumber', 'message']),

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
      // TODO: Instead of using alert, use validation errors
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
main {
  background: var(--grey);
  color: white;
  padding-bottom: 40px;
  border-radius: 12px 12px 0 0;
}
header {
  display: grid;
  grid-template-columns: 33% 33% 33%;
}
h1, h2 {
  font-family: 'Space Mono', monospace;

}
h1 {
  font-size: 1.5rem;
  text-align: center;
  grid-column-start: 2;
}
h3 {
  margin-left: auto;
  font-size: 0.8rem;
}
h2 {
  font-size: 1.3rem;
  text-align: center;
}
.price-input {
  display: flex;
  align-items: center;
  border-style: inset;
  border: 1px solid black;
  border-radius: var(--button-radius);
  justify-content: space-between;
  margin-bottom: 5px;
}
input {
  width: 100%;
}
input::placeholder {
  color: var(--light-grey);
  font-size: 0.8rem;
}
button {
  display: inline-block;
}
.price-summary li {
  display: flex;
}
.price-summary li label {
  width: 100px;
}
.price-summary li:last-child {
  font-size: 1.2rem;
}
.error-list {
  color: red;
}
strong {
  font-weight: bold;
}
form {
  margin: 0 var(--gutter);
  width: 300px;
}
form div {
  margin-bottom: 12px;
}
.input-unit {
  padding: 5px;
}
@media only screen and (max-width: 768px) { 
  p {
    text-align: center;
  }
  header {
    grid-template-columns: 50% 50%;
  }
  h1 {
    grid-column-start: 1;
  }
  button {
    width: 100px;
  }
  form {
    margin: 0 auto;
  }
  h2 {
    margin: 12px 0;
    font-size: 1.6rem;
  }
  h3 {
    text-align: center;
  }
}
</style>


