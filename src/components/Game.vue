<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #{{formatRoundNumber(this.roundNumber())}} </h1>
      <p>Microverse is a simulation. Acquire worlds and power them up to earn a slice of Microverse trade. When trade slows, the simulation stops and riches are airdropped to the least powerful worlds. And the simulation starts over.</p>
    </div>
    <GameInformation :timeLeft="timeLeft" :contract="contractInstance"/>

    <hr/>

    <Board :timeLeft="timeLeft" :contract="contractInstance"/>
    <BuyForm :contract="contractInstance" :referrer="referrer"/>
    <ReferralPrompt :contract="contractInstance"/>
    <a href="https://t.me/microversegame">For latest announcements, feedback, and questions join our telegram</a>
  </div>
</template>

<script>
import { instantiateContract } from './contract'
import { mapActions, mapGetters } from 'vuex'
import MicroverseConfig from '@/Microverse.json'
import contract from 'truffle-contract'
import BuyForm from './BuyForm'
import Board from './Board'
import GameInformation from './GameInformation'
import ReferralPrompt from './ReferralPrompt'
import { formatRoundNumber } from './utils'

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
    ...mapActions(['setTile', 'setRoundNumber', 'setAuctionPrice', 'setJackpot', 'setNextJackpot']),
    ...mapGetters(['roundNumber']),

    formatRoundNumber(roundNumber) {
      return formatRoundNumber(roundNumber)
    },

    // TODO: Include retry logic
    // Sets all initial vuex state related to board state
    async initializeState() {
      const roundNumber = await this.contractInstance.roundNumber()
      this.setRoundNumber(roundNumber)

      if (roundNumber === 0) {
        const auctionPrice = await this.contractInstance.getTilePriceAuction()
        this.setAuctionPrice(auctionPrice)
      } else {
        const jackpot = await this.contractInstance.getJackpot()
        this.setJackpot(jackpot)
      }

      const nextJackpot = await this.contractInstance.getNextJackpot()
      this.setNextJackpot(nextJackpot)

      for (let i = 1; i <= 19; i++) {
        this.setTile({ id: i, contract: this.contractInstance })
      }
    },

    async initializeTimer() {
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
        this.setRoundNumber(res.args.roundNumber.toNumber())
      })

      //contractInstance.instance.GameRoundExtended((err, res) => {
      //  const endTime = res.args.endTime.toNumber()
      //})
      //contractInstance.instance.GameRoundEnded((err, res) => {
      //  const jackpot = res.args.jackpot.toNumber()
      //})

      this.initializeState()
      this.initializeTimer()
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
