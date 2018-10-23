import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
  contract: null,
  tilePrices: {},
}

const actions = {
  setTilePrices({ commit }, { rows, mapping }) {
    rows.forEach(row => {
      row.forEach(async id => {
        const rawPrice = await mapping(id)
        const price = rawPrice.toNumber()
        commit('SET_TILE_PRICE', { id, price })
      })
    })
  }
}

const mutations = {
  UPDATE_STATE(state, { key, value }) {
    state[key] = value
  },
  SET_TILE_PRICE(state, { id, price }) {
    const tiles = Object.assign({}, state.tilePrices)
    tiles[id] = price
    state.tilePrices = tiles
  }
}

const getters = {
  address: state => state.address,
  network: state => state.network,
  contract: state => state.contract,
  price: state => id => state.tilePrices[id]
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})