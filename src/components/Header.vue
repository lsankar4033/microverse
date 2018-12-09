<template>
  <div id="header-container">
    <header v-if="$route.path !== '/'">
      <router-link to="/">
        <div class="logo">Microverse</div>
      </router-link>
      <router-link to="/">
        <span>Back to game</span>
      </router-link>
    </header>
  </div>
</template>

<script>
import { mapActions, mapGetters } from 'vuex'

export default {
  name: 'Header',
  computed: {
    ...mapGetters(['network', 'jackpot']),
  },
  methods: {
    ...mapActions(['setJackpotFromApi']),

    setAddress(address) {
      this.$store.commit('UPDATE_STATE', { key: 'address', value: address || '' })
    },
    setNetwork(id) {
      this.$store.commit('UPDATE_STATE', { key: 'network', value: id || '' })
      if (id !== this.network || !this.jackpot) this.setJackpotFromApi()
    },
    loadWeb3(web3) {
      const provider = web3.currentProvider
      web3.version.getNetwork((err, id) => {
        if (id) this.setNetwork(id)
      })
      this.setAddress(web3.eth.accounts[0])

      // NOTE: Metamask specific!
      provider.publicConfigStore.on('update', user => {
        // NOTE: user.selectedAddress may be undefined.
        this.setAddress(user.selectedAddress)
        // TODO: Check if network is different before actually changing. This method is called a lot.
        this.setNetwork(user.networkVersion)
      })
    }
  },
  mounted() {
    // newer dapp browsers with user-privacy enabled by default
    if (window.ethereum) {
      try {
        window.ethereum.enable().then(() => {
          window.web3 = new window.Web3(window.ethereum)
          this.loadWeb3(window.web3)
        })
      } catch (e) {
        // NOTE: Maybe we should change some state that displays the error
      }
    }

    // old dapp browsers
    else if (window.web3) {
      this.loadWeb3(window.web3)
    }
  },
}
</script>

<style scoped>
header {
	display: flex;
	flex-direction: row;
  padding: .5rem;
  justify-content: space-between;
}

header .menu-items {
	margin-left: auto;
}

header .menu-items span:first-child {
	margin-right: 1rem;
}

header a {
  color: black;
  text-decoration: none;
}

header .logo {
  font-weight: 700;
  text-transform: uppercase;
  font-family: 'Space Mono', monospace;
  color: rgba(0,0,0,.5);
}
</style>
