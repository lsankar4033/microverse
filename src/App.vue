<template>
  <div id="app">
    <Header />
    <router-view />
    <Footer />
  </div>
</template>

<script>
import Header from '@/components/Header.vue'
import Footer from '@/components/Footer.vue'
import { mapActions } from 'vuex'

export default {
  name: 'app',
  components: {
    Header,
    Footer,
  },
  methods: {
    ...mapActions(['setJackpotFromApi']),
    track () {
      this.$ga.page('/')
    }
  },
  mounted() {
    this.track()
    this.setJackpotFromApi()
  }
}
</script>
