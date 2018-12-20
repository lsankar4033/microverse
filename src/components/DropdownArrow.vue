<template>
  <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
    <path class="down" d="M128 192l128 128 128-128z"/>
    <path class="up" d="M128 320l128-128 128 128z"/>
  </svg>
</template>

<script>
export default {
  name: 'DropdownArrow'
}
</script>

<style scoped>
svg {
  min-width: 24px;
  min-height: 24px;
}
.up {
  display: none;
}
.hidden .down {
  display: none;
}
.hidden .up {
  display: block;
}
</style>
