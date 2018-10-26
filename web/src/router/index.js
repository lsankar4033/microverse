import Vue from 'vue'
import Router from 'vue-router'
import Game from '@/components/Game.vue'
import Rules from '@/components/Rules.vue'

Vue.use(Router)

export default new Router({
  mode: 'history',
  routes: [
    {
      path: '/',
      name: 'game',
      component: Game,
      props: (route) => {
        let referrer = typeof(route.query.ref) === 'undefined' ? '0x0' : route.query.ref
        return {referrer: referrer}
      }
    },
    {
      path: '/rules',
      name: 'rules',
      component: Rules
    },
  ]
})
