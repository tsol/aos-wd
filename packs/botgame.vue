<template>
  <div>
    <h1>Bot Game</h1>
    <p>Current state: {{ state }}</p>
  </div>
</template>

<script lang="ts" setup>
import { type State } from './botgame';

const props = defineProps<{
  state?: State
}>();

</script>

