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

Vue.filter('ethToWei', function(eth) {
  if (!eth) return 0
  return eth * 1e18
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

Vue.filter('convertEthToUsd', function(eth, rate) {
  if (!eth) return 0
  return eth * rate
})

Vue.filter('setPrecision', function(value, precision) {
  if (!value) return '0'
  if (!precision) return value
  return value.toPrecision(precision)
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
