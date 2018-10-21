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

export default {
  name: 'Header',
  methods: {
    setAddress(address) {
      this.$store.commit('UPDATE_STATE', { key: 'address', value: address || '' })
    },
    setNetwork(id) {
      this.$store.commit('UPDATE_STATE', { key: 'network', value: id || '' })
    },
    setContract(contract) {
      // console.log('contract', contract)
      const contractClone = Object.assign({}, contract)
      // console.log('contractClone', contractClone)
      // TODO: Fix this issue.
      this.$store.commit('UPDATE_STATE', { key: 'contract', value: contractClone || {} })
    }
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
    this.$store.commit('UPDATE_STATE', { })
    const abstractContract = contract(MicroverseConfig)
    abstractContract.setProvider(provider)
    abstractContract.deployed().then(contractInstance => {
      // console.log('contractInstance', contractInstance)
      this.setContract(contractInstance)
    })
  },
}
</script>
