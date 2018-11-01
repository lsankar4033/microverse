<template>
  <div>
    <h3 id="testnet-instructions">Testnet instructions</h3>
    <p>Thank you for testing the prototype of Microverse! The only thing you need to know in addition to what&#39;s below is that the game is on Ropsten. So you&#39;ll have to switch your network from Mainnet to Ropsten in Metamask. If you don&#39;t have Ropsten Ether, visit:</p>
    <ul>
      <li><a href="https://faucet.ropsten.be/">https://faucet.ropsten.be/</a></li>
      <li><a href="https://faucet.metamask.io/">https://faucet.metamask.io/</a></li>
    </ul>
    <p>And get 1 ETH from each. </p>
    <p>Please just play the game like a self-interested player (want to earn money, have fun). If you can break the game, that would be awesome. The player with the most winnings in the testnet round will get something special. </p>
    <h3 id="game-overview">Game overview</h3>
    <p>Microverse is a simulated universe controlled by powerful aliens. The universe has many worlds that can be bought, sold, and powered. Owners of these worlds receive a cut of the Microverse economy. Worlds are always for sale, so ambitious Microverse-ians are always scheming for a big cut.</p>
    <p>The aliens are happy if the Microverse economy grows, but if too much time passes between transactions in the world, they throw their hands up, dump a stimulus on the worlds that seem to be the most behind, and start the simulation over.</p>
    <h3 id="the-concept">The concept</h3>
    <p>There are two games to play and win in Microverse.</p>
    <ol>
      <li>Owners of worlds receive a cut of the Microverse economy. The higher the price of your world, the larger cut of each Microverse transaction you get.</li>
      <li>When a simulation ends, the cheapest world in the universe receives a huge stimulus. Timing the end of the simulation just right and positioning your worlds to win the stimulus could help you win the jackpot.</li>
    </ol>
    <h3 id="the-rules">The rules</h3>
    <ul>
      <li>Microverse contains 37 worlds</li>
      <li>Every world is always for sale</li>
      <li>At the start of the simulation, worlds are unowned, and are sold via an hour long dutch auction where the price slowly declines towards zero until the world is sold</li>
      <li>Owners can change the price of their worlds, but have to pay a 10% tax on the difference between the current price and a higher price (no tax for decreasing the price). To decrease the price, users pay a flat 0.01 ETH fee (this is simply to prevent spam)</li>
      <li>All transactions in Microverse go directly through the Microverse economy (see figure below for the exact splits), with roughly half going towards the stimulus (jackpot) and the other half going instantly to the owners of worlds</li>
      <li>As soon as the first world is sold, a 24 hour countdown begins. When the countdown reaches zero, the simulation ends and the stimulus is distributed</li>
      <li>Each time a world is purchased or the price is changed the timer goes up 30 seconds to a maximum of 24 hours.</li>
      <li>At the end of the simulation, the player who owns the world that is least powerful compared to its neighbors (lowest market price compared to the average of all its neighbors) wins half of the stimulus. The rest is distributed proportionally to the next least powerful worlds.</li>
    </ul>

    <br/>

    <h2 id="microverse-economy-splits">Microverse economy splits</h2>
    <p>Every ETH that flows through the Microverse economy is allocated as follows:</p>
    <ul>
      <li>40% to the stimulus</li>
      <li>38% to current owners of worlds</li>
      <li>12% to developers</li>
      <li>5% to the referrer</li>
      <li>5% to seed the stimulus of the next simulation</li>
    </ul>

    <br/>

    <h2 id="stimulus-splits">Stimulus splits</h2>
    <p>At the end of a simulation, 45% of the stimulus is sent directly to the owner of the world with the lowest price and 5% is sent to devs.</p>
    <p>The remaining 50% is distributed as follows:</p>
    <ul>
      <li>40% to the owners of worlds, sorted by lowest price</li>
      <li>10% to seed the next round</li>
    </ul>
    <h2 id="refer-your-friends-and-earn-money">Refer your friends and earn money</h2>
    <p>Invite your friends to play and earn 5% of what they spend when they use your link. No fee to them. You can find your referral link on the <a href="/">homepage</a>.</p>
    <h3 id="setup">Setup</h3>
    <p>You will need ETH and a crypto browser to play Microverse.</p>
    <ul>
      <li>For playing on desktop, please use <a href="https://metamask.io/">metamask</a></li>
      <li>For playing on mobile, please download the mobile crypto wallet you prefer. We recommend <a href="https://wallet.coinbase.com/">Coinbase Wallet</a> or <a href="https://trustwalletapp.com/">Trust Wallet</a></li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'Rules'
}
</script>
