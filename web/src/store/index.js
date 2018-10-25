import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const deselectedTile = {
  id: -1,
  price: 0,
  owner: null,
}

const state = {
  address: '',
  network: '',
  domain: 'http://microverse.com',
  tile: deselectedTile,
}

const actions = {
  deselectTile({ commit }) {
    commit('UPDATE_STATE', { key: 'tile', value: deselectedTile })
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
  tile: state => state.tile,
  domain: state => state.domain,
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})