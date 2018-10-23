import Vue from 'vue'
import Vuex from 'vuex'
Vue.use(Vuex)

const state = {
  address: '',
  network: '',
  gameState: 0,
  contract: null,
  tiles: {},
}

const actions = {
  setTiles({ commit }, { rows, priceMapping, ownerMapping }) {
    const nullAddress = '0x0000000000000000000000000000000000000000'

    rows.forEach(row => {
      row.forEach(async id => {
        const rawPrice = await priceMapping(id)
        const rawOwner = await ownerMapping(id)
        const price = rawPrice.toNumber()
        const owner = rawOwner === nullAddress ? null : rawOwner
        commit('SET_TILE', { id, price, owner })
      })
    })
  },
  async buyTile({ commit, state }, { id, newPrice }) {
    if (!state.contract) return
    if (!state.address) return
    const instance = await state.contract.deployed()
    const stage = await instance.stage()
    const price = stage.toNumber() === 0
      ? await instance.getTilePriceAuction()
      : await instance.tileToPrice(id)
    instance.buyTileAuction.sendTransaction(parseInt(id), parseInt(newPrice), { from: state.address, value: price, gas: 3000000})
  },
}

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
  contract: state => state.contract,
  gameState: state => state.gameState,
  price: state => id => {
    const tile = state.tiles[id]
    if (!tile) return null
    if (!tile.owner && state.gameState === 0) return 'Auction'
    return tile.price
  },
  owner: state => id => {
    if (!state.tiles[id]) return null
    return state.tiles[id].owner
  },
  tile: state => id => {
    return state.tiles[id]
  },
}

export default new Vuex.Store({
  state,
  getters,
  actions,
  mutations
})