<template>
  <v-list>
    <v-list-item v-for="process in props.processes" :key="process.pid" :active="process.pid === props.modelValue"
      class="pointer" @click="() => $emit('update:modelValue', process.pid)">
      <v-list-item-title>
        {{ shortenCutMiddle(process.name, 25) }}
      </v-list-item-title>
      <v-list-item-subtitle>
        {{ shortenCutMiddle(process.pid, 15) }}
      </v-list-item-subtitle>
      <!-- <v-list-item-action>
        <v-icon>mdi-close</v-icon>
      </v-list-item-action> -->
    </v-list-item>
  </v-list>
</template>

<script lang="ts" setup>
import type { Process } from '~/store/persist';
import { shortenCutMiddle } from '~/lib/utils';

const props = defineProps<{
  processes: Process[];
  modelValue: string | undefined;
}>();

</script>

<style scoped>
.pointer {
  cursor: pointer;
}
</style>
