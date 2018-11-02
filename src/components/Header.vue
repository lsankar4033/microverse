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
      provider.enable().then(address => {
        if (address && address.length > 0) this.setAddress(address[0])
      })
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
        ethereum.enable().then((r) => {
          window.web3 = new Web3(ethereum)
          this.loadWeb3(window.web3)
        })
      } catch (e) {
        // NOTE: Maybe this should be a message about not approving metamask
        console.log("User didn't approve site!")
      }
    }

    // old dapp browsers
    else if (window.web3) {
      this.loadWeb3(window.web3)
    }
  },
}
</script>
