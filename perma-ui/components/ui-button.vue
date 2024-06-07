<template>
  <VBtn @click="onClick" :disabled="uiLoading || !isValid">
    <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
  </VBtn>
</template>

<script setup lang="ts">
import { computed } from 'vue';

import type { State } from '../lib/ui-state-parser';
import type { InitVueParams } from '../lib/vue-init';

import { runCommand } from './shared/runCommand';

import { VBtn } from 'vuetify/components';

const cProps = defineProps<{
  uiValid?: string;
  uiLoading?: boolean;

  uiRun: string;
  uiArgs?: Record<string, any>;
  aoSendMsg: InitVueParams['aoSendMsg'],

  inputsValidity?: Record<string, boolean>
  state?: State['ui'],

}>();

const myInputs = cProps.uiValid?.split(/[\s,]+/) || [];
const isValid = computed(() => myInputs.every((input) => cProps.inputsValidity?.[input]));

function onClick() {
  if (!isValid.value) return;
  runCommand(cProps);
}

</script>
../lib/ui-base../lib/vue-inside-vue../lib/ui-state-parser../../core/parser