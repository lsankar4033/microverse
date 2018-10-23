import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
}

const actions = {}

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    state[key] = value
  },
  SET_TILE(state, { id, price, owner }) {
    const tiles = Object.assign({}, state.tiles)
    tiles[id] = { price, owner }
    state.tiles = tiles
  },
}

const getters = {
  address: state => state.address,
  network: state => state.network,
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})