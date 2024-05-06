<template>
    <input-by-type
        v-bind="$attrs"
        :type="uiType"
        :model-value="modelValue"
        :optional="!uiRequired"
        @update:model-value="(val: any) => modelValue = val"
        @update:safe-value="(val: any) => safeModelValue = val"
        @valid="validityChanged"
      />
</template>

<script setup lang="ts">

import type { State } from './ui';
import InputByType from './input/by-type.vue';
import type { INPUTS_MAP } from './input/inputs.interface';

const props = defineProps<{
  uiId: keyof State;
  uiType: keyof typeof INPUTS_MAP,
  uiRequired?: boolean,
  state?: State['ui'],
  inputsValidity?: Record<string, boolean>
}>();

const modelValue = ref<any>(props.state?.[props.uiId] || '');

const safeModelValue =  computed({
  get: () => props.state?.[props.uiId] || '',
  set: (value: any) => {
    if (! props.state ) {
      return;
    }
    props.state[props.uiId] = value;
  }
});

function validityChanged(isValid: boolean) {
  console.log('validityChanged', isValid);
  if (! props.inputsValidity) {
    return;
  }
  props.inputsValidity[props.uiId] = isValid;
}

</script>
