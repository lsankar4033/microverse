<template>
  <SectionShell class="section-accent">
    <div>
      <p class="label">Simulation #001</p>
      <p v-if="jackpot"><b>Stimulus (jackpot):</b> Ξ{{ jackpot | weiToEth }}</p>
      <p v-if="auctionPrice"><b>Auction Tile Price:</b> Ξ{{ auctionPrice | weiToEth | setPrecision(8) }}</p>
      <p v-if="timeLeft"><b>Time left:</b> {{ timeLeft | formatSecondsToTime }}</p>
    </div>
    <div v-if="contract" class="withdraw-container">
      <p v-if="balance > 0">Balance</p>

      <footer>
        <p v-if="balance > 0">
          <span v-if="status == 'withdrawSuccess'">Tell your friends you earned</span> Ξ{{ balance | weiToEth | setPrecision(8) }}
        </p>
        <button v-if="balance > 0 && !status" class="button" @click="withdraw">Withdraw</button>
        <SocialShare v-if="status == 'withdrawSuccess'" :tweet="`I just earned ${balanceInEth} eth in Microverse ${domain}`" />
      </footer>
    </div>
  </SectionShell>
</template>

<script>
import { mapGetters } from 'vuex'
import SectionShell from './SectionShell'
import SocialShare from './SocialShare'

export default {
  name: 'GameInformation',
  props: ['contract', 'timeLeft'],
  components: {
    SectionShell,
    SocialShare,
  },
  data() {
    return {
      balance: 0,
      status: '',
    }
  },
  computed: {
    ...mapGetters(['address', 'domain']),
    jackpot() {
      if (!this.contract) return null
      return this.contract.jackpot
    },
    auctionPrice() {
      if (!this.contract) return null
      return this.contract.auctionPrice
    },
    balanceInEth() {
      return this.$options.filters.weiToEth(this.balance)
    }
  },
  methods: {
    async getBalance() {
      this.status = ''
      this.balance = await this.contract.getBalance(this.address)
      if (!this.balance || this.balance == 0) this.status = 'noBalance'
    },
    async withdraw() {
      const success = await this.contract.withdraw(this.address)
      if (!success) return
      this.status = 'withdrawSuccess'
    },
  },
  mounted() {
    this.$store.subscribe(async (mutation) => {
      if (mutation.type == 'UPDATE_STATE' && mutation.payload.key == 'address') {
        this.balance = await this.contract.getBalance(this.address)
      }
    })
  },
  watch: {
    async contract (newContract) {
      if (newContract != null && this.address != null) {
        this.balance = await this.contract.getBalance(this.address)
      }
    }
  },
}
</script>

<style scoped>
.link {
  cursor: pointer;
  text-decoration: underline;
}
.withdraw-container p {
  text-align: right;
}
.withdraw-container a {
  text-align: right;
  text-decoration: underline;
  cursor: pointer;
}
.withdraw-container footer {
  display: flex;
  flex-direction: column;
}
.withdraw-container footer p {
  margin: 0 0 10px 0;
}
.withdraw-container footer button {
  margin-left: auto;
}
.social-icons {
  justify-content: flex-end;
}
@media only screen and (max-width: 768px) {
  .withdraw-container {
    display: flex;
    flex-direction: column;
  }
  .withdraw-container p {
    text-align: left;
  }
  .withdraw-container footer button {
    margin-left: 0;
    margin-right: auto;
  }
  .social-icons {
    justify-content: flex-start;
  }
}
</style>
