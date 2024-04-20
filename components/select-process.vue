<template>
  <v-combobox label="A process ID or process name"
    hint="Select a process from the list of your processes." v-model="selectedProcess"
    :items="persist.processes" :return-object="false" item-title="name" item-value="pid" clearable
    @click:clear="console.log('clear')">
    <template #item="{ item, props }">
      <v-list-item v-bind="props" title="">
        <v-list-item-title>
          {{ item.raw.name }}
        </v-list-item-title>
        <v-list-item-subtitle>
          {{ item.raw.pid }}
        </v-list-item-subtitle>
      </v-list-item>
    </template>

  </v-combobox>
</template>

<script lang="ts" setup>
import { usePersistStore } from '~/store/persist';

const props = defineProps<{
  modelValue: string | undefined;
}>();

const emit = defineEmits<{
  (event: 'update:modelValue', value: string): void,
}>();

const persist = usePersistStore();

const selectedProcess = computed({
  get: () => props.modelValue || '',
  set: (val) => {
    emit('update:modelValue', val);
  }
});


</script>
