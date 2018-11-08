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
  message: {
    active: false,
    text: '',
  },
  domain: 'http://microverse.com',
  selectedTile: deselectedTile,
  tiles: {},
}

const actions = {
  deselectTile({ commit }) {
    commit('UPDATE_STATE', { key: 'selectedTile', value: deselectedTile })
  },
  async setTile({ commit }, { id, contract }) {
    if (!contract) return
    const tile = await contract.getTile(id)
    commit('UPDATE_TILE', { id, tile })
    return tile
  }
}

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    state[key] = value
  },
  UPDATE_TILE(state, { id, tile }) {
    const tiles = Object.assign({}, state.tiles)
    tiles[id] = tile
    state.tiles = tiles
  },
  SHOW_MESSAGE(state, { text }) {
    const message = Object.assign({}, state.message)
    message.text = text
    message.active = true
    state.message = message
  },
  HIDE_MESSAGE(state) {
    const message = Object.assign({}, state.message)
    message.active = false
    state.message = message
  },
}

const getters = {
  address: state => state.address,
  network: state => state.network,
  selectedTile: state => state.selectedTile,
  domain: state => state.domain,
  tile: state => id => state.tiles[id],
  message: state => state.message,
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})