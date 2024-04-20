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
      <v-list-item @click="doForget">
        <v-list-item-title>Forget process</v-list-item-title>     
      </v-list-item>
      <v-list-item @click="doResetCursor">
        <v-list-item-title>Reset cursor (no fetch history)</v-list-item-title>     
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script lang="ts" setup>
import { useProcesses } from '#imports';
import { usePersistStore } from '~/store/persist';

const persist = usePersistStore();

const props = defineProps<{
  pid: string;
}>();

const ao = useProcesses();

const dialogOpen = ref(false);

function doDisconnect() {
  ao.disconnect(props.pid)
  persist.setCurrentPid(undefined);
  dialogOpen.value = false;
}

async function doForget() {
  await ao.disconnect(props.pid)
  persist.removeProcess(props.pid);
  persist.setCurrentPid(undefined);
  dialogOpen.value = false;
}

function doResetCursor() {
  persist.updateCursor(props.pid, undefined);
  dialogOpen.value = false;
}

</script>

<style></style>