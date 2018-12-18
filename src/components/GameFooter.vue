<template>
  <main>
    <div>
      <h1>Jackpot</h1>
      <h2><EthSymbol/>39.432</h2>
    </div>
    <button>
      <svg version="1.1" role="presentation" width="25" height="25" viewBox="0 0 512 512">
        <path :d="infoIcon"></path>
      </svg>
      <span>
        How to Play
      </span>
    </button>
  </main>
</template>

<script>
const infoIcon = 'M256 48C141.2 48 48 141.2 48 256s93.2 208 208 208 208-93.2 208-208S370.8 48 256 48zm21 312h-42V235h42v125zm0-166h-42v-42h42v42z'

export default {
  name: 'GameFooter',
  data() {
    return {
      infoIcon,
    }
  },
}
</script>

<style scoped>
main {
  background: var(--dark-blue);
  display: flex;
  justify-content: space-between;
  color: white;
  padding: 6px var(--gutter);
}
h2 {
  font-family: 'Space Mono', monospace;
  font-size: 1.5rem;
}
svg {
  fill: white;
}
@media only screen and (max-width: 768px) { 
  main {
    flex-direction: column;
  }
  div {
    text-align: center;
  }
}
</style>
