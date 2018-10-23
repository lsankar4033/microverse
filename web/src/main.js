import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router'
import moment from 'vue-moment'

Vue.use(moment)
Vue.config.productionTip = false

Vue.filter('weiToEth', function(wei) {
  if (!wei) return 0
  return wei / 1e18
})

new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
