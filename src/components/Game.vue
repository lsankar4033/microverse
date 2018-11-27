<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #{{formatRoundNumber(this.roundNumber())}} </h1>
      <p style="font-style:italic">In a galaxy far far away, a powerful alien race builds a tiny, simulated universe. They call it, the Microverse. Players are inhabitants of the Microverse and do capitalist things, taking and losing control of worlds until the aliens get impatient and reset the simulation, awarding stimuluses to the least developed worlds starting a new round.</p>
    </div>
    <GameInformation :timeLeft="timeLeft" :contract="contractInstance"/>

    <hr/>

    <Board :timeLeft="timeLeft" :contract="contractInstance"/>
    <BuyForm :contract="contractInstance" :referrer="referrer"/>
    <ReferralPrompt :contract="contractInstance"/>
    <a href="https://t.me/joinchat/F50acRJqamZqxUANfFhckg">For latest announcements, feedback, and questions join our telegram</a>
    <a href="https://twitter.com/microversegame" class="twitter-follow-button" data-show-count="false">Follow @MicroverseGame</a>
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

const delay = t => new Promise(resolve => setTimeout(resolve, t));

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

      // TODO: Change timer in UI!
      //contractInstance.instance.GameRoundExtended((err, res) => {
      //  const endTime = res.args.endTime.toNumber()
      //})

      // TODO: Set up 'End round' button, etc.
      //contractInstance.instance.GameRoundEnded((err, res) => {
      //  const jackpot = res.args.jackpot.toNumber()
      //})

      this.initializeState()
      this.initializeTimer()

      // https://stackoverflow.com/questions/45047126/how-to-add-external-js-scripts-to-vuejs-components
      const twitterScript = document.createElement('script')
      twitterScript.setAttribute('src', 'https://platform.twitter.com/widgets.js')
      document.head.appendChild(twitterScript)
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
