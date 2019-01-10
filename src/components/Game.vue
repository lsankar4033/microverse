<template>
  <div id="game-board">
    <div class="game-container">
      <GameInformation :timeLeft="timeLeft" :contract="contractInstance"/>
      <Board :timeLeft="timeLeft" :contract="contractInstance"/>
      <BuyForm v-if="selectedTile.id >= 0" :contract="contractInstance" :referrer="referrer"/>
      <GameFooter />
    </div>
    <ReferralPrompt :contract="contractInstance"/>
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
import GameFooter from './GameFooter'
import ReferralPrompt from './ReferralPrompt'
// import { formatRoundNumber } from './utils'

// const delay = t => new Promise(resolve => setTimeout(resolve, t));

export default{
  name: 'Game',
  props: ['referrer'],
  components: {
    BuyForm,
    GameInformation,
    Board,
    ReferralPrompt,
    GameFooter,
  },
  data() {
    return {
      contractInstance: null,
      timeLeft: null,
      timeoutPointer1: null,
      timeoutPointer2: null,
    }
  },
  computed: {
    ...mapGetters(['selectedTile']),
  },
  methods: {
    ...mapActions(['setTile', 'setRoundNumber', 'setAuctionPrice', 'setJackpot', 'setNextJackpot']),

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
        // this.setJackpot(jackpot)
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
      const interval = 1000 // ms
      let expected = Date.now() + interval
      const that = this
      this.timeoutPointer1 = setTimeout(step, interval)
      function step() {
          const dt = Date.now() - expected // the drift (positive for overshooting)
          if (dt > interval) {
              // something really bad happened. Maybe the browser (tab) was inactive?
              // possibly special handling to avoid futile "catch up" run
          }
          expected += interval
          that.timeLeft -= interval / 1000
          that.timeoutPointer2 = setTimeout(step, Math.max(0, interval - dt)) // take into account drift
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

      contractInstance.instance.GameRoundExtended((err, res) => {
        if (this.timeoutPointer1) clearTimeout(this.timeoutPointer1)
        if (this.timeoutPointer2) clearTimeout(this.timeoutPointer2)
        const end = res.args.endTime.toNumber()
        const now = + new Date() / 1000
        this.timeLeft = end - now
        this.startTimer()
      })

      // TODO: Set up 'End round' button, etc.
      //contractInstance.instance.GameRoundEnded((err, res) => {
      //  const jackpot = res.args.jackpot.toNumber()
      //})

      this.initializeState()
      this.initializeTimer()
    })
    // https://stackoverflow.com/questions/45047126/how-to-add-external-js-scripts-to-vuejs-components
    const twitterScript = document.createElement('script')
    twitterScript.setAttribute('src', 'https://platform.twitter.com/widgets.js')
    document.head.appendChild(twitterScript)
  },
}
</script>

<style scoped>
#game-board {
  display: flex;
  flex-direction: column;
  align-items: center;
  background-image: linear-gradient(to right, var(--sea-green), white);
}
.game-container {
  border: 5px solid var(--dark-blue);
  border-radius: 6px;
  background-image: radial-gradient(var(--light-sea-blue), var(--navy-blue));
  width: var(--game-board-width);
  margin-top: 20px;
}
@media only screen and (max-width: 768px) {
  .game-container {
    width: 100%;
    margin-top: 0;
  }
}
</style>
