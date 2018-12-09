<template>
  <main>
    <div>
      <h1>Jackpot</h1>
      <h2><EthSymbol/>39.432</h2>
    </div>
    <button>
      How to Play
    </button>
  </main>
</template>

<script>
export default {
  name: 'GameFooter'
}
</script>

<style scoped>
main {
  background: #888;
  display: flex;
  justify-content: space-between;
}
h1 {
  font-family: 'Work Sans', sans-serif;
}
h2 {
  font-family: 'Space Mono', monospace;
}
button {
  font-family: 'Space Mono', monospace;
  background: red;
  color: white;
  border-radius: 45px;
  padding: 4px 20px;
}
</style>
