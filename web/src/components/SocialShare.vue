<template>
  <div class="social-icons">
    <SocialIcon type="facebook" />
    <SocialIcon type="twitter" :tweet="tweet" />
    <!-- <SocialIcon type="mail" /> -->
  </div>
</template>

<script>
import SocialIcon from './SocialIcon'

export default {
  name: 'SocialShare',
  props: ['tweet'],
  components: {
    SocialIcon
  },
}
</script>

<style>
.social-icons {
  display: flex;
}
</style>
