import Vue from 'vue'
import Router from 'vue-router'

// import Tutorial from '@/components/Tutorial.vue'
// import MyVault from '@/components/MyVault.vue'
import GameBoard from '@/components/GameBoard.vue'
import Rules from '@/components/Rules.vue'
// import BuyModal from '@/components/BuyModal.vue'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'game_board',
      component: GameBoard
    },
    {
      path: '/rules',
      name: 'rules',
      component: Rules
    },
  ]
})
