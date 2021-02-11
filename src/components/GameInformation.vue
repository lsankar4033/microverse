<template>
  <SectionShell class="section-accent">
    <div>
      <ul>
        <li class="label">Simulation #{{formatRoundNumber(this.roundNumber())}}</li>
        <li v-if="jackpot"><b>Stimulus (jackpot):</b> Ξ{{ this.jackpot | weiToEth }}<span @click="updateGame" class="refresh-button"><Refresh /></span></li>
        <li v-if="auctionPrice && roundNumber() === 0"><b>Auction Tile Price:</b> Ξ{{ this.auctionPrice | weiToEth | setPrecision(8) }}<span @click="updateGame" class="refresh-button"><Refresh /></span></li>
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
    </div>
  </SectionShell>
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
    ...mapActions(['setAuctionPrice', 'setJackpot', 'setNextJackpot', 'setRoundNumber']),

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
        this.setJackpot(jackpot)
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
.refresh-button {
  cursor: pointer;
  margin-left: 4px;
  display: flex;
}
ul {
  list-style-type: none;
  padding: 0
}
ul li {
  margin: 0.5rem 0;
  display: flex;
  align-items: center;
}
b {
  margin-right: 5px;
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
  ul li {
    flex-direction: column;
  }
}
</style>
