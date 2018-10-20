<template>
  <div id="header-container">
    <header>
      <router-link to="/">
        <div class="logo">Microverse</div>
      </router-link>

      <div class="menu-items">
        <router-link to="/tutorial">
          <span>How to play</span>
        </router-link>

        <router-link to="/my_vault">
          <span>My vault</span>
        </router-link>
      </div>
    </header>
  </div>
</template>

<script>
import MicroverseConfig from '@/Microverse.json'
import contract from 'truffle-contract'
import { mapActions } from 'vuex'

export default {
  name: 'Header',
  methods: {
    ...mapActions(['getContract']),

    setAddress(address) {
      this.$store.commit('UPDATE_STATE', { key: 'address', value: address || '' })
    },
    setNetwork(id) {
      this.$store.commit('UPDATE_STATE', { key: 'network', value: id || '' })
    },
    setContract(contract) {
      this.$store.commit('UPDATE_STATE', { key: 'contract', value: contract || {} })
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
    const abstractContract = contract(MicroverseConfig)
    abstractContract.setProvider(provider)
    this.setContract(abstractContract)
  },
}
</script>
