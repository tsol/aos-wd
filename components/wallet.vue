<template>
  <div class="w-100">
    <div v-if="!connected" class="d-flex align-center justify-space-between">
      <div><a href="https://arconnect.io">Don't have an Arweave Wallet?</a></div>
      <div>
        <v-btn @click="arConnect" class="mr-2" variant="outlined">
          <v-icon start>mdi-wallet</v-icon>
          CONNECT
        </v-btn>
      </div>
    </div>

    <div v-else class="d-flex align-center justify-space-between">
      <div>Wallet connected</div>
      <div>
        <v-btn @click="arDisconnect" variant="outlined">
          <v-icon start>mdi-wallet</v-icon>
          DISCONNECT
        </v-btn>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { useWallet } from '~/composables/useWallet';
const { connected, arConnect, arDisconnect } = useWallet();

</script>