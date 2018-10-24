import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
  tile: {
    id: -1,
    price: 0,
    owner: null,
  },
}

const actions = {}

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    state[key] = value
  },
}

const getters = {
  address: state => state.address,
  network: state => state.network,
  tile: state => state.tile,
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})