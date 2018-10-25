<template>
  <SectionShell class="section-accent">
    <div>
      <p class="label">Simulation #001</p>
      <p><b>Stimulus (jackpot):</b> Ξ{{ jackpot | weiToEth }} (${{ jackpot | weiToEth | convertEthToUsd(ethToUsdRate) }})</p>
      <p><b>Time left:</b> {{ timeLeft | formatSecondsToTime }}</p>
    </div>
    <div class="withdraw-container">
      <p @click.prevent="getBalance" class="label link">Check Balance</p>
      <footer>
        <p><span v-if="status">Tell your friends you earned</span> Ξ{{ balance | weiToEth }}</p>
        <button v-if="balance > 0 && !status" class="button" @click="withdraw">Withdraw</button>
        <SocialShare v-if="status" />
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
      ethToUsdRate: 200,
      status: '',
    }
  },
  computed: {
    ...mapGetters(['address']),
    jackpot() {
      if (!this.contract) return 'Loading'
      return this.contract.jackpot
    },
  },
  methods: {
    async getBalance() {
      this.status = ''
      this.balance = await this.contract.getBalance(this.address)
    },
    async withdraw() {
      const success = await this.contract.withdraw(this.address)
      if (!success) return
      this.status = 'withdrawSuccess'
    },
  }
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
