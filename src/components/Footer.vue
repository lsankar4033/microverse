<template>
  <main>
    <ul>
      <li><strong>Microverse 2018</strong></li>
      <li class="spacer">-</li>
      <li>How To Play</li>
      <li class="spacer">-</li>
      <li>T&C</li>
      <li class="spacer">-</li>
      <li>Source Code</li>
      <li class="spacer">-</li>
      <li>Contact</li>
    </ul>
  </main>
</template>

<script>
export default {
  name: 'Footer',
}
</script>

<style scoped>
main {
  background: var(--dark-blue);
  padding: 35px;
  color: white;
  display: flex;
  justify-content: center;
  font-family: 'Space Mono', monospace;
}
ul {
  display: flex;
  font-size: 10pt;
}
strong {
  font-weight: bold;
}
.spacer {
  margin: 0 12px;
}
</style>
