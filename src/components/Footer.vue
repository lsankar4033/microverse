<template>
  <main>
    <ul>
      <li><a href="/"><strong>Microverse 2018-2019</strong></a></li>
      <li class="spacer">-</li>
      <li><a href="/rules">How To Play</a></li>
      <li class="spacer">-</li>
      <li>T&C</li>
      <li class="spacer">-</li>
      <li>Source Code</li>
      <li class="spacer">-</li>
      <li><a :href="TELEGRAM_URL">Contact</a></li>
    </ul>
  </main>
</template>

<script>
import { mapGetters } from 'vuex'

export default {
  name: 'Footer',
  computed: {
    ...mapGetters(['TELEGRAM_URL']),
  }
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
a {
  text-decoration: none;
}
@media only screen and (max-width: 768px) { 
  ul {
    display: grid;
    grid-template-columns: repeat(5, 20%);
  }
  li {
    word-break: break-word;
    padding: 3px;
    margin: auto auto;
    text-align: center;
  }
  .spacer {
    display: none;
  }
  main {
    padding: 0;
  }
}
</style>
