<template>
  <main>
    <header>
      <h1>Refer a friend</h1>
      <p>Refer friends and earn 5% of all taxes they pay. <br> No fee to them.</p>
    </header>
    <div>
      <span>
        <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
          <path d="M74.6 256c0-38.3 31.1-69.4 69.4-69.4h88V144h-88c-61.8 0-112 50.2-112 112s50.2 112 112 112h88v-42.6h-88c-38.3 0-69.4-31.1-69.4-69.4zm85.4 22h192v-44H160v44zm208-134h-88v42.6h88c38.3 0 69.4 31.1 69.4 69.4s-31.1 69.4-69.4 69.4h-88V368h88c61.8 0 112-50.2 112-112s-50.2-112-112-112z"/>
        </svg>
        <input readonly="readonly" :value="refUrl" />
      </span>
      <button>Copy Link</button>
    </div>
  </main>
  <!-- <div id="referral-prompt" class="section section-accent">
    <p>Refer friends and earn 5% of all taxes they pay. No fee to them.</p>
      <p>
        <input id="referral-url" readonly="readonly" v-bind:value="referralUrl()"/>

        <span @click="copyReferralToClipboard" class="button inline">
            <i class="fas fa-link"></i>Copy link
        </span>
    </p>
  </div> -->
</template>

<script>
import { mapGetters } from 'vuex'

// NOTE: Probably should move these to utils file
const microverseUrl = 'https://microversegame.com'
function copyStringToClipboard (str) {
   // Create new element
   var el = document.createElement('textarea');
   // Set value (string to be copied)
   el.value = str;
   // Set non-editable to avoid focus and move outside of view
   el.setAttribute('readonly', '');
   el.style = {position: 'absolute', left: '-9999px'};
   document.body.appendChild(el);
   // Select text inside element
   el.select();
   // Copy text to clipboard
   document.execCommand('copy');
   // Remove temporary element
   document.body.removeChild(el);
}

export default{
  name: 'ReferralPrompt',
  props: ['contract'],
  computed: {
    ...mapGetters(['address']),
    refUrl() {
      return `${microverseUrl}?ref=${this.address}`
    }
  },
  methods: {
      referralUrl() {
          return `${microverseUrl}?ref=${this.address}`
      },
      copyReferralToClipboard() {
          copyStringToClipboard(this.referralUrl())
      }
  }
}
</script>

<style scoped>
main {
  width: var(--game-board-width);
}
header {
  margin: 12px var(--gutter);
}
h1 {
  color: var(--dark-blue);
  font-weight: bold;
  font-size: 1.3rem;
  letter-spacing: 1px;
  margin-bottom: 5px;
}
div {
  display: flex;
  justify-content: center;
}
svg {
  width: 36px;
  height: 36px;
  margin: 0 6px;
  fill: var(--grey);
  cursor: pointer;
}
span {
  background: white;
  display: flex;
  align-items: center;
  border-radius: var(--button-radius);
  flex: 5;
}
input {
  width: 100%;
}
button {
  background: var(--dark-blue);
}
@media only screen and (max-width: 768px) {
  main {
    width: 100%;
  }
}
/* #referral-prompt {
	display: flex;
	flex-direction: column;
	width: auto;
  background-color: rgba(243,244,123,1)
}

input#referral-url {
    background-color: white;
}

.button.inline {
  font-size: .8rem;
  padding: .25rem .5rem;
  background-color: rgba(0,0,0,.66);
  cursor: pointer;
}

.button.inline:hover {
  background-color: rgba(0,0,0,.33);
} */
</style>
