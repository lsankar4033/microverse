<template>
    <div id="referral-prompt" class="section section-accent">
        <p>Refer friends and earn 5% of all taxes they pay. No fee to them.</p>
        <p>
            <input id="referral-url" readonly="readonly" v-bind:value="referralUrl()"/>

            <span @click="copyReferralToClipboard" class="button inline">
                <i class="fas fa-link"></i>Copy link
            </span>
        </p>
    </div>
</template>

<script>
import { mapGetters } from 'vuex'

// NOTE: Probably should move these to utils file
const microverseUrl = 'microverse.com'
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
#referral-prompt {
	display: flex;
	flex-direction: column;
	width: auto;
	padding: .5rem;
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
}
</style>
