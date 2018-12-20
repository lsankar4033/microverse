<template>
  <main>
    <h1>
      In a galaxy far far away, a powerful alien race builds a tiny, simulated universe. They call it, the Microverse. Players are inhabitants of the Microverse and do capitalist things, taking and losing control of worlds until the aliens get impatient and reset the simulation, awarding stimuluses to the least developed worlds starting a new round.
    </h1>
    <section>
      <header>
        <DropdownArrow/>
        <h2 @click="toggleActive">Overview</h2>
      </header>
      <p>At the beginning of the game, 19 worlds are auctioned off via Dutch auction. Once all of the 19 worlds are sold, the round begins</p>
      <p>During the round, worlds are always for sale. Their owners must always set a list price. Owners are taxed 10% of the list price. These taxes fund the Microverse economy. Roughly half goes towards the stimulus. The other half trickles down to the owners of the 19 worlds</p>
      <p>The round ends when the timer reaches zero. The timer starts at a max length of 12 hours and resets (back to the max length) each time a user pays a tax. The max length halves each time 10 ETH are paid in taxes.</p>
      <p>When the round ends, the half of the stimulus is awarded to the lowest price world and the other half trickles through the worlds with lower priced worlds getting more of the stimulus. Then the round restarts.</p>
    </section>
    <section>
      <header>
        <DropdownArrow/>
        <h2 @click="toggleActive">The concept</h2>
      </header>
      <p>There are two games to play and win in Microverse.</p>
      <ol>
        <li>Owners of worlds receive a cut of the Microverse economy. The higher the price of your world, the larger cut of each Microverse transaction you get.</li>
        <li>When a simulation ends, the lowest priced world in the universe receives a huge stimulus. Timing the end of the simulation just right and positioning your worlds to win the stimulus could help you win the jackpot.</li>
      </ol>
    </section>
    <section>
      <header>
        <DropdownArrow/>
        <h2 @click="toggleActive">The rules</h2>
      </header>
    <ul>
      <li>Microverse contains 19 worlds</li>
      <li>Every world is always for sale</li>
      <li>At the start of the simulation, worlds are unowned, and are sold via dutch auction where the price slowly declines towards zero until the world is sold</li>
      <li>Owners can change the price of their worlds, but have to pay a 10% tax on the new price</li>
      <li>All transactions in Microverse go directly through the Microverse economy (see figure below for the exact splits), with roughly half going towards the stimulus and the other half going instantly to the owners of worlds (pro rata based on relative share of the total price of all worlds)</li>
      <li>As soon all worlds are sold, a the round begins and the round timer starts counting down from 12 hours</li>
      <li>Each time a world is purchased or the price is changed the timer is reset, starting with 12 hours and halving every 10 ETH that flow through the Microverse</li>
      <li>At the end of the simulation, the player who owns the lowest price world wins half of the stimulus (in the event of a tie, the winnings are split evenly). The rest is distributed proportionally rest of the worlds (pro rata based on the inverse of the relative share of the total price of all worlds)</li>
      <li>A new round begins with ownership of worlds unchanged</li>
    </ul>
    </section>
    <section>
      <header>
        <DropdownArrow/>
        <h2 @click="toggleActive">The economy</h2>
      </header>
      <h3>Microverse economy splits</h3>
      <p>Every ETH that flows through the Microverse economy is allocated as follows:</p>
      <ul>
        <li>40% to the stimulus</li>
        <li>38% to current owners of worlds</li>
        <li>12% to developers</li>
        <li>5% to the referrer</li>
        <li>5% to seed the stimulus of the next simulation</li>
      </ul>
      <h3>Stimulus splits</h3>
      <p>At the end of a simulation, 45% of the stimulus is sent directly to the owner of the world with the lowest price and 5% is sent to devs.</p>
      <p>The remaining 50% is distributed as follows:</p>
      <ul>
        <li>40% to the owners of worlds, sorted by lowest price</li>
        <li>10% to seed the next round</li>
      </ul>
    </section>
    <section>
      <header>
        <DropdownArrow/>
        <h2 @click="toggleActive">Refer your friends and earn money</h2>
      </header>
      <p>Invite your friends to play and earn 5% of what they spend when they use your link. No fee to them. You can find your referral link on the <a href="/">homepage</a>.</p>
    </section>
    <section>
      <header>
        <DropdownArrow />
        <h2 @click="toggleActive">Setup</h2>
      </header>
      <p>You will need ETH and a crypto browser to play Microverse.</p>
      <ul>
        <li>For playing on desktop, please use <a href="https://metamask.io/">metamask</a></li>
        <li>For playing on mobile, please download the mobile crypto wallet you prefer. We recommend <a href="https://wallet.coinbase.com/">Coinbase Wallet</a> or <a href="https://trustwalletapp.com/">Trust Wallet</a></li>
      </ul>
    </section>
  </main>
</template>

<script>
import DropdownArrow from '@/components/DropdownArrow'
export default {
  name: 'Rules',
  components: {
    DropdownArrow,
  },
  methods: {
    toggleActive(e) {
      e.target.parentNode.parentNode.classList.toggle('hidden')
    },
    track () {
      this.$ga.page('/rules')
    },
  },
  mounted() {
    this.track()
  }
}
</script>

<style scoped>
main {
  padding: var(--gutter);
}
section {
  margin-bottom: 25px;
}
h1 {
  font-style: italic;
  margin-bottom: 10px;
}
h2 {
  font-size: 1.5rem;
  font-weight: 500;
  margin: 15px 0;
}
header {
  display: flex;
  align-items: center;
  cursor: pointer;
}
h3 {
  font-weight: 400;
  font-size: 1.3rem;
  margin: 5px 0;
}
p {
  margin-bottom: 15px;
}
ul {
  padding-left: 2.5rem;
}
li {
  display: list-item;
  margin-bottom: 10px;
}
ul li {
  list-style-type: disc;
}
ol li {
  list-style-type: decimal;
}
.hidden > * {
  display: none;
}
.hidden > header {
  display: flex;
}
</style>
