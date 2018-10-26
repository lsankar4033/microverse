<template>
    <div id="referral-prompt" class="section section-accent">
        <p>Refer friends and earn 10% of what they spend. No fee to them.</p>
        <p>
        <input id="referral-url" readonly="readonly" v-bind:value="referralUrl()"/>

            <!-- TODO: Make this button work -->
            <span class="button inline">
                <i class="fas fa-link"></i>Copy link
            </span>
        </p>
    </div>
</template>

<script>
import { mapGetters } from 'vuex'

// NOTE: Probably should put this in a utils file
const microverseUrl = 'microverse.com'

export default{
    name: 'ReferralPrompt',
    props: ['contract'],
    computed: {
        ...mapGetters(['address']),
    },
    methods: {
        referralUrl() {
            return `${microverseUrl}?ref=${this.address}`
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
