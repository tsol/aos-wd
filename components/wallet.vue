<template>
  <div>
    <v-btn @click="arConnect" v-if="!connected" >
      AR CONNECT
    </v-btn>
    <v-btn v-else @click="arDisconnect" variant="outlined">
        DISCONNECT
    </v-btn>   
    <a href="https://arconnect.io">Don't have an Arweave Wallet?</a>
  </div>
</template>

<script lang="ts" setup>
import { useWallet } from '~/composables/useWallet';
const { connected, arConnect, arDisconnect } = useWallet();

</script>