<template>
  <div class="section rules">
    <h1 id="how-to-play">How to play</h1>
    <h2 id="the-concept">The concept</h2>
    <p>There are two games to play and win in Microverse.</p>
    <ol>
      <li>Owners of worlds receive a cut of the Microverse economy. The higher the price of your world, the larger cut of each Microverse transaction you get.</li>
      <li>When a simulation ends, the lowest priced world in the universe receives a huge stimulus. Timing the end of the simulation just right and positioning your worlds to win the stimulus could help you win the jackpot.</li>
    </ol>
    <h2 id="the-rules">The rules</h2>
    <ul>
      <li>Microverse contains 19 worlds</li>
      <li>Every world is always for sale</li>
      <li>At the start of the simulation, worlds are unowned, and are sold via dutch auction where the price slowly declines towards zero until the world is sold</li>
      <li>Owners can change the price of their worlds, but have to pay a 10% tax on the new price</li>
      <li>All transactions in Microverse go directly through the Microverse economy (see figure below for the exact splits), with roughly half going towards the stimulus (jackpot) and the other half going instantly to the owners of worlds</li>
      <li>As soon all worlds are sold, a the round begins and the round timer starts counting down from 12 hours</li>
      <li>Each time a world is purchased or the price is changed the timer is reset, starting with 12 hours and halving every 10 ETH that flow through the Microverse</li>
      <li>At the end of the simulation, the player who owns the lowest price world wins half of the stimulus. The rest is distributed proportionally rest of the worlds</li>
      <li>A new round begins with ownership of worlds unchanged</li>
    </ul>
    <h3 id="microverse-economy-splits">Microverse economy splits</h3>
    <p>Every ETH that flows through the Microverse economy is allocated as follows:</p>
    <ul>
      <li>40% to the stimulus</li>
      <li>38% to current owners of worlds</li>
      <li>12% to developers</li>
      <li>5% to the referrer</li>
      <li>5% to seed the stimulus of the next simulation</li>
    </ul>
    <h3 id="stimulus-splits">Stimulus splits</h3>
    <p>At the end of a simulation, 45% of the stimulus is sent directly to the owner of the world with the lowest price and 5% is sent to devs.</p>
    <p>The remaining 50% is distributed as follows:</p>
    <ul>
      <li>40% to the owners of worlds, sorted by lowest price</li>
      <li>10% to seed the next round</li>
    </ul>
    <h2 id="refer-your-friends-and-earn-money">Refer your friends and earn money</h2>
    <p>Invite your friends to play and earn 5% of what they spend when they use your link. No fee to them. You can find your referral link on the <a href="/">homepage</a>.</p>
    <h2 id="setup">Setup</h2>
    <p>You will need ETH and a crypto browser to play Microverse.</p>
    <ul>
      <li>For playing on desktop, please use <a href="https://metamask.io/">metamask</a></li>
      <li>For playing on mobile, please download the mobile crypto wallet you prefer. We recommend <a href="https://wallet.coinbase.com/">Coinbase Wallet</a> or <a href="https://trustwalletapp.com/">Trust Wallet</a></li>
    </ul>
    <br/><br/>
  </div>
</template>

<script>
  export default {
    name: 'Rules'
  }
</script>

<style scoped>
ul {
  list-style-type: disc;
  padding-left: 2.5rem;
}
ul li {
  display: list-item;
}
</style>
