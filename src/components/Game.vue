<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #001</h1>
      <p>Microverse is a simulation. Acquire worlds and power them up to earn a slice of Microverse trade. When trade slows, the simulation stops and riches are airdropped to the least powerful worlds. And the simulation starts over.</p>
    </div>
    <GameInformation :timeLeft="timeLeft" :contract="contractInstance"/>

    <hr/>

    <ReferralPrompt :contract="contractInstance"/>
    <Board :timeLeft="timeLeft" :contract="contractInstance"/>
    <BuyForm :contract="contractInstance" :referrer="referrer"/>
  </div>
</template>

<script>
import { instantiateContract } from './contract'
import { mapActions } from 'vuex'
import MicroverseConfig from '@/Microverse.json'
import contract from 'truffle-contract'
import BuyForm from './BuyForm'
import Board from './Board'
import GameInformation from './GameInformation'
import ReferralPrompt from './ReferralPrompt'

export default{
  name: 'Game',
  props: ['referrer'],
  components: {
    BuyForm,
    GameInformation,
    Board,
    ReferralPrompt,
  },
  data() {
    return {
      contractInstance: null,
      timeLeft: null,
    }
  },
  methods: {
    ...mapActions(['setTile']),

    async initializeCountDown() {
      const timeLeft = await this.contractInstance.getTimeRemaining()
      this.timeLeft = timeLeft
      this.startTimer()
    },
    startTimer() {
      // https://stackoverflow.com/questions/29971898/how-to-create-an-accurate-timer-in-javascript
      const interval = 1000; // ms
      let expected = Date.now() + interval;
      const that = this
      setTimeout(step, interval);
      function step() {
          const dt = Date.now() - expected; // the drift (positive for overshooting)
          if (dt > interval) {
              // something really bad happened. Maybe the browser (tab) was inactive?
              // possibly special handling to avoid futile "catch up" run
          }
          expected += interval;
          that.timeLeft -= interval / 1000
          setTimeout(step, Math.max(0, interval - dt)); // take into account drift
      }
    }
  },
  mounted() {
    if (!window.web3) return
    const abstractContract = contract(MicroverseConfig)
    abstractContract.setProvider(window.web3.currentProvider)
    instantiateContract(abstractContract).then(contractInstance => {
      this.contractInstance = contractInstance
      contractInstance.instance.TileOwnerChanged((err, res) => {
        this.setTile({ id: res.args.tileId.toNumber(), contract: contractInstance })
      })
      contractInstance.instance.TilePriceChanged((err, res) => {
        this.setTile({ id: res.args.tileId.toNumber(), contract: contractInstance })
      })
      contractInstance.instance.GameRoundStarted((err, res) => {
        const initJackpot = res.args.initJackpot.toNumber()
        console.log('initJackpot', initJackpot)
        const endTime = res.args.endTime.toNumber()
        console.log('endTime', endTime)
      })
      contractInstance.instance.GameRoundExtended((err, res) => {
        const endTime = res.args.endTime.toNumber()
        console.log('res', endTime)
      })
      contractInstance.instance.GameRoundEnded((err, res) => {
        const jackpot = res.args.jackpot.toNumber()
        console.log('jackpot', jackpot)
      })
      this.initializeCountDown()
    })
  },
}
</script>

<style scoped>
.section-body {
  position: relative;
  padding: 0;
}
</style>
