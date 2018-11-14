<template>
  <div id="header-container">
    <header>
      <router-link to="/">
        <div class="logo">Microverse</div>
      </router-link>

      <div class="menu-items">
        <router-link to="rules" v-if="$route.path == '/'">
          <span>How to play</span>
        </router-link>
        <router-link to="/" v-else>
          <span>Back to game</span>
        </router-link>

      </div>
    </header>
  </div>
</template>

<script>
export default {
  name: 'Header',
  methods: {
    setAddress(address) {
      this.$store.commit('UPDATE_STATE', { key: 'address', value: address || '' })
    },
    setNetwork(id) {
      this.$store.commit('UPDATE_STATE', { key: 'network', value: id || '' })
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
