<template>
  <v-menu offset-y>
    <template v-slot:activator="{ props }">
      <slot v-bind="props">
        <v-icon v-bind="props">mdi-dots-horizontal</v-icon>
      </slot>
    </template>
    <v-list>
      <v-list-item @click="doDisconnect">
        <v-list-item-title>Disconnect</v-list-item-title>
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script lang="ts" setup>
import { useProcesses } from '#imports';
const props = defineProps<{
  pid: string;
}>();

const ao = useProcesses();

const dialogOpen = ref(false);

function doDisconnect() {
  ao.disconnect(props.pid)
  dialogOpen.value = false;
}

</script>

<style></style>