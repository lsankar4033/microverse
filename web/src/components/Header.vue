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
  },
  mounted() {
    const web3 = window.web3

    if (!web3) return
    const provider = web3.currentProvider

    web3.version.getNetwork((err, id) => {
      if (id) this.setNetwork(id)
    })
    provider.enable().then(address => {
      if (address && address.length > 0) this.setAddress(address[0])
    })
    window.web3.currentProvider.publicConfigStore.on('update', user => {
      // NOTE: user.selectedAddress may be undefined.
      this.setAddress(user.selectedAddress)
      this.setNetwork(user.networkVersion)
    })
    // const abstractContract = contract(MicroverseConfig)
    // abstractContract.setProvider(provider)
    // this.setContract(abstractContract)
  },
}
</script>
