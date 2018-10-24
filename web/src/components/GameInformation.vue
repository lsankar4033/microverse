<template>
  <SectionShell class="section-accent">
    <div>
      <p class="label">Simulation #001</p>
      <p><b>Stimulus (jackpot):</b> Ξ{{ jackpot | weiToEth }} (${{ jackpot | weiToEth | convertEthToUsd(ethToUsdRate) }})</p>
      <p><b>Time left:</b> {{ timeLeft | formatSecondsToTime }}</p>
    </div>
    <div class="withdraw-container" v-if="balance > 0">
      <p class="label">Balance</p>
      <p>Ξ{{ balance }}</p>
      <button class="button">Withdraw</button>
    </div>
  </SectionShell>
</template>

<script>
import SectionShell from './SectionShell'
import { mapGetters } from 'vuex'

export default {
  name: 'GameInformation',
  props: ['contract', 'timeLeft'],
  components: {
    SectionShell,
  },
  data() {
    return {
      balance: 12.3421,
      ethToUsdRate: 200,
    }
  },
  computed: {
    jackpot() {
      if (!this.contract) return 'Loading'
      return this.contract.jackpot
    }
  },
}
</script>

<style>
.withdraw-container p {
  text-align: right;
}
</style>
