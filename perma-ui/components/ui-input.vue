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
import { ref, computed } from 'vue';

import type { State } from '../lib/ui-state-parser';
import type { INPUTS_MAP } from './input/inputs.interface';

import InputByType from './input/by-type.vue';

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
  // console.log('validityChanged', isValid);
  if (! props.inputsValidity) {
    return;
  }
  props.inputsValidity[props.uiId] = isValid;
}

</script>
../lib/ui-base