<template>
  <div id="game-board">
    <div class="section hero">
      <h1>Welcome to simulation #001</h1>
      <p>Microverse is a simulation. Acquire worlds and power them up to earn a slice of Microverse trade. When trade slows, the simulation stops and a riches are airdropped to the worlds least powerful relative to their neighbors. And the simulation starts over.</p>
    </div>
    <div class="section section-accent">
      <p class="label">Simulation #001</p>
      <p><b>Stimulus (jackpot):</b> Ξ203.55 ($10000)</p>
      <p><b>Time left:</b> 11h 33m 22s</p>
    </div>
    <div class="section section-body">
      <p class="label">Click to acquire a world</p>
      <div class="grid">
        <div class="row">
          <div class="hex">
            &#x2B22;
            <p>Ξ1</p>
          </div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
        </div>
        <div class="row">
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex owned">&#x2B22;<p>Ξ1</p></div>
          <div class="hex owned">&#x2B22;<p>Ξ1</p></div>
          <div class="hex">&#x2B22;</div>
        </div>
        <div class="row">
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
        </div>
        <div class="row">
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
        </div>
        <div class="row">
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
        </div>
        <div class="row">
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
        </div>
        <div class="row">
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
          <div class="hex">&#x2B22;</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default{
  name: 'GameBoard'
}
</script>
