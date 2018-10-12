import Vue from 'vue'
import Router from 'vue-router'

import Tutorial from '@/components/Tutorial.vue'
import MyVault from '@/components/MyVault.vue'
import GameBoard from '@/components/GameBoard.vue'

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
      path: '/tutorial',
      name: 'tutorial',
      component: Tutorial
    },
    {
      path: '/my_vault',
      name: 'my_vault',
      component: MyVault
    }
  ]
})
