<template>
  <svg @click.prevent="handleClick" class="social-icon" version="1.1" role="presentation" width="25" height="25" viewBox="0 0 512 512"><path :d="mapping[type]"></path></svg>
</template>

<script>
const mapping = {
  facebook: 'M426.8 64H85.2C73.5 64 64 73.5 64 85.2v341.6c0 11.7 9.5 21.2 21.2 21.2H256V296h-45.9v-56H256v-41.4c0-49.6 34.4-76.6 78.7-76.6 21.2 0 44 1.6 49.3 2.3v51.8h-35.3c-24.1 0-28.7 11.4-28.7 28.2V240h57.4l-7.5 56H320v152h106.8c11.7 0 21.2-9.5 21.2-21.2V85.2c0-11.7-9.5-21.2-21.2-21.2z',
  twitter: 'M492 109.5c-17.4 7.7-36 12.9-55.6 15.3 20-12 35.4-31 42.6-53.6-18.7 11.1-39.4 19.2-61.5 23.5C399.8 75.8 374.6 64 346.8 64c-53.5 0-96.8 43.4-96.8 96.9 0 7.6.8 15 2.5 22.1-80.5-4-151.9-42.6-199.6-101.3-8.3 14.3-13.1 31-13.1 48.7 0 33.6 17.2 63.3 43.2 80.7-16-.4-31-4.8-44-12.1v1.2c0 47 33.4 86.1 77.7 95-8.1 2.2-16.7 3.4-25.5 3.4-6.2 0-12.3-.6-18.2-1.8 12.3 38.5 48.1 66.5 90.5 67.3-33.1 26-74.9 41.5-120.3 41.5-7.8 0-15.5-.5-23.1-1.4C62.8 432 113.7 448 168.3 448 346.6 448 444 300.3 444 172.2c0-4.2-.1-8.4-.3-12.5C462.6 146 479 129 492 109.5z',
  // mail: 'M437.332 80H74.668C51.199 80 32 99.198 32 122.667v266.666C32 412.802 51.199 432 74.668 432h362.664C460.801 432 480 412.802 480 389.333V122.667C480 99.198 460.801 80 437.332 80zM432 170.667L256 288 80 170.667V128l176 117.333L432 128v42.667z'
}

// const email = {
//   emailSubject: 'Play Microverse',
//   emailBody: `Hey There\n check out this new game on Ethereum`,
// }

export default {
  name: 'SocialIcon',
  props: ['type', 'tweet'],
  data() {
    return {
      mapping,
      // email,
    }
  },
  computed: {
    pageLink() {
      const fullPath = process.browser
        ? window.location.origin + this.$route.fullPath
        : this.$route.fullPath
      return fullPath
    },
    // shareEmail() {
    //   const str = `?cc=reid%40tokengifts.net
    //     &subject=${encodeURIComponent(this.email.emailSubject)}
    //     &body=${encodeURIComponent(this.email.emailBody)}`
    //   return `mailto:${str}`
    // },
  },
  methods: {
    handleClick() {
      const tweet = this.tweet ? this.tweet : 'Check out microverse'
      switch(this.type) {
        case 'facebook':
          window.open(`http://www.facebook.com/sharer.php?u=${encodeURI(this.pageLink)}`, 'Share', 'width=600,height=400')
          break
        case 'twitter':
          window.open(`https://twitter.com/intent/tweet?text=${encodeURIComponent(tweet)}`, 'Share', 'width=600,height=400')          
          break
      }
    },
  }
}
</script>

<style scoped>
  svg {
    cursor: pointer
  }
</style>

