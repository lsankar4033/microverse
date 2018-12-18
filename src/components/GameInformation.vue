<template>
  <main>
    <!-- Logo w/ round number <-> My balance w/ amount -->
    <!-- Time remaining (auction or round) <-> Withdraw button -->
    <!-- auction price or extension duration <-> end round button -->
    <!-- Stimulus shows up on bottom of screen now -->
    <section>
      <ul>
        <li>
          <h1>Microverse</h1>
          <aside>
            <small>Simulation</small>
            <small>#001</small>
          </aside>
        </li>
        <li>
          1 day 14:20:19 left
        </li>
      </ul>
      <ul>
        <li>My Balance</li>
        <li><EthSymbol /> 0.0005</li>
        <li><button>Withdraw</button></li>
      </ul>
    </section>
    <!-- <div>
      <div class="logo">Microverse</div>
      <ul>
        <li class="label">Simulation #{{formatRoundNumber(this.roundNumber())}}</li>
        <li v-if="jackpot"><b>Stimulus (jackpot):</b> Ξ{{ this.jackpot | weiToEth }}<span @click="updateGame" class="refresh-button"><Refresh /></span></li>
        <li v-if="auctionPrice"><b>Auction Tile Price:</b> Ξ{{ this.auctionPrice | weiToEth | setPrecision(8) }}<span @click="updateGame" class="refresh-button"><Refresh /></span></li>
        <li v-if="timeLeft && roundNumber() > 0"><b>Time left:</b> {{ timeLeft | formatSecondsToTime }}</li>
        <li v-if="extensionDuration > 0"><b>Extension duration:</b> {{ extensionDuration | formatSecondsToShortTime }}</li>
      </ul>
    </div>
    <div v-if="contract" class="withdraw-container">
      <p>Balance</p>

      <footer>
        <p>
          <span v-if="status == 'withdrawSuccess'">Tell your friends you earned</span>
          Ξ{{ balance | weiToEth | setPrecision(8) }}
        </p>
        <button v-if="balance > 0 && !status" class="button" @click="withdraw">Withdraw</button>
        <SocialShare v-if="status == 'withdrawSuccess'" :tweet="`I just earned ${balanceInEth} eth in Microverse ${domain}`" />
      </footer>
    </div> -->
  </main>
</template>

<script>
import { mapGetters, mapActions } from 'vuex'
import SectionShell from './SectionShell'
import SocialShare from './SocialShare'
import Refresh from './Refresh'
import { formatRoundNumber } from './utils'

export default {
  name: 'GameInformation',
  props: ['contract', 'timeLeft'],
  components: {
    SectionShell,
    SocialShare,
    Refresh,
  },
  data() {
    return {
      balance: 0,
      status: '',
      extensionDuration: 0,
    }
  },
  computed: {
    ...mapGetters(['address', 'domain', 'auctionPrice', 'jackpot']),
    balanceInEth() {
      return this.$options.filters.weiToEth(this.balance)
    },
  },
  methods: {
    ...mapGetters(['roundNumber']),
    ...mapActions(['setAuctionPrice', 'setNextJackpot', 'setRoundNumber']),

    async getBalance() {
      this.status = ''
      this.balance = await this.contract.getBalance(this.address)
      if (!this.balance || this.balance == 0) this.status = 'noBalance'
    },
    async setExtensionDuration() {
      const seconds = await this.contract.getCurrentRoundExtension()
      this.extensionDuration = seconds
    },
    async withdraw() {
      const success = await this.contract.withdraw(this.address)
      if (!success) return
      this.status = 'withdrawSuccess'
    },

    // NOTE: Duplicate logic with Game.vue...
    async updateGame() {
      const roundNumber = await this.contract.roundNumber()
      this.setRoundNumber(roundNumber)

      if (roundNumber === 0) {
        const auctionPrice = await this.contract.getTilePriceAuction()
        this.setAuctionPrice(auctionPrice)
      } else {
        const jackpot = await this.contract.getJackpot()
        // Handled by API instead
        // this.setJackpot(jackpot)
      }

      const nextJackpot = await this.contract.getNextJackpot()
      this.setNextJackpot(nextJackpot)
    },
    formatRoundNumber(roundNumber) {
      return formatRoundNumber(roundNumber)
    },
  },
  async mounted() {
    if (this.address !== '' && this.contract != null) {
      this.balance = await this.contract.getBalance(this.address)
      this.setExtensionDuration()
    }

    this.$store.subscribe(async (mutation) => {
      if (mutation.type == 'UPDATE_STATE' && mutation.payload.key == 'address') {
        this.balance = await this.contract.getBalance(this.address)
        this.setExtensionDuration()
      }
    })
  },
  watch: {
    async contract (newContract) {
      if (newContract != null && this.address != null) {
        this.balance = await this.contract.getBalance(this.address)
        this.setExtensionDuration()
      }
    },
    timeLeft: function(tl) {
      if (!tl || tl < 1) {
        this.$ga.event({
          eventCategory: 'error',
          eventAction: 'timeleft failure',
          eventLabel: 'timeleft is either undefined or less than 1',
        })
      }
    }
  },
}
</script>

<style scoped>
main {
  color: white;
  padding: 6px var(--gutter);
}
section {
  display: flex;
  justify-content: space-between;
}
h1 {
  font-family: 'Space Mono', monospace;
  text-transform: uppercase;
  font-size: 22px;
  letter-spacing: 1.5px;
  color: var(--light-grey);
}
small {
  font-size: 8px;
}
li {
  font-family: 'Space Mono', monospace;
}
li:first-child {
  display: flex;
}
aside {
  display: flex;
  flex-direction: column;
  justify-content: center;
}
@media only screen and (max-width: 768px) {
  section {
    flex-direction: column;
  }
  ul:first-child {
    margin: 0 auto 10px;
  }
  ul:last-child {
    display: grid;
    grid-template-rows: 50% 50%;
    grid-template-columns: 50% 50%;
  }
  ul:last-child li {
    text-align: center;
    margin: 0 auto;
  }
  ul:last-child li:last-child {
    grid-column: 1 / span 2;
  }
  ul {
    margin-bottom: 15px;
  }
}
</style>
