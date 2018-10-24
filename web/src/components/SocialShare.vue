<template>
  <div class="social-icons">
    <SocialIcon type="facebook" />
    <SocialIcon type="twitter" />
    <SocialIcon type="mail" />
  </div>
</template>

<script>
import SocialIcon from './SocialIcon'

export default {
  name: 'SocialShare',
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
