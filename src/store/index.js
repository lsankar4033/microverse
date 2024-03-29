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

  domain: 'https://www.microversegame.com',

  selectedTile: deselectedTile,

  tiles: {},
  roundNumber: null,
  auctionPrice: null,
  jackpot: null,
  nextJackpot: null
}

const actions = {
  deselectTile({ commit }) {
    commit('UPDATE_STATE', { key: 'selectedTile', value: deselectedTile })
  },

  async setTile({ commit, state }, { id, contract }) {
    if (!contract) return
    const tile = await contract.getTile(id, state)
    commit('UPDATE_TILE', { id, tile })
    return tile
  },

  setRoundNumber({ commit }, roundNumber) {
    commit('UPDATE_ROUND_NUMBER', roundNumber)
  },
  setAuctionPrice({ commit }, auctionPrice) {
    commit('UPDATE_AUCTION_PRICE', auctionPrice)
  },
  setJackpot({ commit }, jackpot) {
    commit('UPDATE_JACKPOT', jackpot)
  },
  setNextJackpot({ commit }, nextJackpot) {
    commit('UPDATE_NEXT_JACKPOT', nextJackpot)
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
  UPDATE_ROUND_NUMBER(state, roundNumber) {
    state.roundNumber = roundNumber
  },
  UPDATE_AUCTION_PRICE(state, auctionPrice) {
    state.auctionPrice = auctionPrice
  },
  UPDATE_JACKPOT(state, jackpot) {
    state.jackpot = jackpot
  },
  UPDATE_NEXT_JACKPOT(state, nextJackpot) {
    state.nextJackpot = nextJackpot
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
  roundNumber: state => state.roundNumber,
  auctionPrice: state => state.auctionPrice,
  jackpot: state => state.jackpot,
  nextJackpot: state => state.nextJackpot
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})
