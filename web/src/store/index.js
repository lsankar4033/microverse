import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
  contract: null,
}

const actions = {
  async getContract({ state }) {
    const instance = await state.contract.deployed()
    return instance
  }
}

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    state[key] = value
  },
}

const getters = {
  address: state => state.address,
  network: state => state.network,
  contract: state => state.contract,
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})