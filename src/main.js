import Vue from 'vue'
import App from './App.vue'
import store from './store'
import router from './router'
import moment from 'vue-moment'
import VueAnalytics from 'vue-analytics'
import Big from 'big.js'

Vue.use(moment)

Vue.use(VueAnalytics, {
  id: 'UA-26259984-6'
})

Vue.config.productionTip = false

Vue.filter('weiToEth', function(wei) {
  if (!wei) return 0
  const t = new Big(wei)
  const result = t.div('1e+18')
  return result.toString()
})

Vue.filter('ethToWei', function(eth) {
  if (!eth) return 0
  const t = new Big(eth)
  const result = t.times('1e+18')
  return result.toString()
})

Vue.filter('formatSecondsToTime', function(sec) {
  // https://stackoverflow.com/questions/1322732/convert-seconds-to-hh-mm-ss-with-javascript
  if (!sec || sec < 0) return null
  let totalSeconds = sec
  let hours = Math.floor(totalSeconds / 3600)
  const days = Math.floor(hours / 24)
  hours %= 24
  totalSeconds %= 3600
  const minutes = Math.floor(totalSeconds / 60)
  const seconds = Math.floor(totalSeconds % 60)
  return `${days} days ${hours} hrs ${minutes} min ${seconds} s`
})

Vue.filter('setPrecision', function(value, precision) {
  if (!value) return '0'
  if (!precision) return value
  const t = new Big(value)
  const result = t.toFixed(precision)
  return result.toString()
})

Vue.filter('hashShorten', function(hash) {
  if (!hash) return ''
  return `${hash.substr(0,6)}...${hash.substr(hash.length - 6)}`
})


new Vue({
  router,
  store,
  render: h => h(App)
}).$mount('#app')
