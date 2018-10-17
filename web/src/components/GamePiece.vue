<template>
  <div class="frame" @click="openModal">
    <div class="hex-outer h1"></div>
    <div class="hex-outer h2"></div>
    <div class="hex-outer h3"></div>
    <div class="hex-inner h1">
      <span class="hex-label">Hello</span>
    </div>
    <div class="hex-inner h2"></div>
    <div class="hex-inner h3"></div>
    <!-- <div class="label">+</div> -->
  </div>
</template>

<script>
export default {
  name: 'GamePiece',
  props: ['owned', 'value'],
  methods: {
    openModal() {
      console.log('hi')
    },
  }
}
</script>

<style scoped>
/* https://codepen.io/aslan11/pen/amekH */
:root {
  --color: red;
  --framewidth: 210px;
  --outlinewidth: 10px;
}

.frame {
  width: var(--framewidth);
  height: 0px;
  /* margin: 0 auto; */
  /* margin-top: 20px; */
  position: relative;
  cursor: pointer;
}

.hex-outer {
  background: var(--color);
  width: var(--framewidth);
  height: 120px;
}

.hex-inner {
  background: #373940;
  --width: calc(var(--framewidth) - var(--outlinewidth));
  width: var(--width);
  height: 115px;
  position: relative;
  --left: calc(var(--outlinewidth) / 2);
  left: var(--left);
  top: 82px !important;
  border-radius: 0;
}

.h1 {
  position: absolute;
  top: 80px;
  display: flex;
}

.hex-label {
  position: relative;
  margin: auto;
  color: white;
  z-index: 999;
}

.h2 {
  position: absolute;
  top: 80px;
  transform: rotate(60deg);
  -webkit-transform: rotate(60deg);
}

.h3 {
  position: absolute;
  top: 80px;
  transform: rotate(-60deg);
  -webkit-transform: rotate(-60deg);
}

/* .label {
  position: absolute;
  color: #ABF8FF;
  font-weight: bold;
  font-size: 160px;
  left: 59px;
  top: 36px;
} */

</style>
