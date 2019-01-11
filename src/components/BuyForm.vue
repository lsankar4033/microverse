<template>
  <main>
    <header>
      <h1>World {{ selectedTile.id }}</h1>
      <h3>Owned by {{ selectedTile.owner | hashShorten }}</h3>
    </header>
    <h2><EthSymbol/>{{ price | weiToEth }}</h2>
    <form>
      <div>Set your listing price</div>
      <div>
        <span class="price-input">
          <EthSymbol class="input-unit" />
          <input v-model="newPrice" type="number" placeholder="Enter a number less than 3.234" v-on:input="handleInput">
          <button @click.prevent="handleChangePrice" :disabled="validationErrors.length > 0 || newPrice.length < 1">Buy</button>
        </span>
        <ul class="error-list">
          <li v-for="error in validationErrors">
            <aside v-html="error"/>
          </li>
        </ul>
      </div>
      <ul class="price-summary">
        <li><label>Price</label><p>{{ newPrice || '0'}}</p></li>
        <li><label>Tax</label><p>{{ tax | weiToEth }}</p></li>
        <hr/>
        <li><label>Total</label><p><strong>{{ total | weiToEth }}</strong></p></li>
      </ul>
    </form>
  </main>
</template>

<script>
import { mapGetters, mapActions, mapMutations } from 'vuex'
import SectionShell from './SectionShell'
import SocialShare from './SocialShare'

const METAMASK_URL = 'https://metamask.io/'

export default {
  name: 'BuyForm',
  props: ['contract', 'referrer'],
  components: {
    SectionShell,
    SocialShare
  },
  data() {
    return {
      // validationErrors: [`You must be logged into <a href="${METAMASK_URL}">metamask</a> or similar wallet provider`, `Price is too high (max: GET_MAX_FROM_API)`],
      validationErrors: [],
      newPrice: '',
      // tileBought or priceChanged
      status: '',
      tax: 0,
      total: 0,
    }
  },
  computed: {
    ...mapGetters(['address', 'selectedTile', 'domain', 'roundNumber', 'message', 'userIsLoggedIntoWalletProvider']),

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

    handleInput() {
      this.updateTotal()
      this.setValidationErrorsFromNewPrice()
    },
    setValidationErrorsFromNewPrice() {
      const price = this.newPrice
      const validationErrors = []
      const messages = {
        noLogin: `You must be logged into <a href="${METAMASK_URL}">metamask</a> or similar wallet provider`,
        priceLow: `New price must be greater than 0 wei`,
        priceHigh: `New price must be less than current stimulus (INSERT PRICE HERE)`,
      }
      if (!this.userIsLoggedIntoWalletProvider) validationErrors.push(messages['noLogin'])
      if (price <= 1e-18 && price.length > 0) validationErrors.push(messages['priceLow'])
      // TODO: Price too high validation message check
      this.validationErrors = validationErrors
    },
    async handleBuyTile() {
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
button[disabled] {
  background: var(--light-grey);
  cursor: default;
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
ul {
  width: 500px;
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


