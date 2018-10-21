import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
  contract: {},
}

// No async actions required, yet.
// const actions = {
//   setAddress({ commit }, address) {
//     updateAddress(...) {}
//   }
// }

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    state[key] = value
  },
}

const getters = {
  address: state => state.address,
  network: state => state.network,
}

export default new Vuex.Store({
  state,
  getters,
  mutations
})