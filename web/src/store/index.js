import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
  contract: null,
  tile: null,
}

const actions = {
  // We can put the contract instance directly into state now?
  // async getContract({ state }) {
  //   if (!state.contract) return
  //   const instance = await state.contract.deployed()
  //   return instance
  // }
  async setTile({ commit }) {
    console.log('here')
    commit('UPDATE_STATE', { key: 'tile', value: 10})
  }
}

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    console.log('value', value)
    state[key] = value
  },
}

const getters = {
  address: state => state.address,
  network: state => state.network,
  contract: state => state.contract,
  tile: state => state.tile
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})