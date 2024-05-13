<template>
  <VBtn
    @click="onClick"
    :disabled="uiLoading || !isValid"
  >
    <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
  </VBtn>
</template>

<script setup lang="ts">
import { computed } from 'vue';

import type { State } from '../lib/ui-state-parser';
import type { InitVueParams } from '../lib/vue-init';

import { parseLuaObject } from '../../core/parser';

import { VBtn } from 'vuetify/components';

const props = defineProps<{
  uiValid?: string;
  uiRun: string;
  uiLoading?: boolean;

  inputsValidity?: Record<string, boolean>
  aoSendMsg: InitVueParams['aoSendMsg'],
  state?: State['ui'],
  
}>();

const myInputs = props.uiValid?.split(/[\s,]+/) || [];

const isValid = computed(() => myInputs.every((input) => props.inputsValidity?.[input]));

function onClick() {
  if (!isValid.value) return;

const match = props.uiRun.match(/([^(]+)\((\{.+\})?\)/);
if (!match) {
  console.error('Invalid ui-run:', props.uiRun);
  return;
}

const command = match[1].trim();
const args = match[2]?.replace(/[']+/g, '"');

const cmdArgs = args ? args.replace(/\$([a-zA-Z_][a-zA-Z0-9_]*)/g, (_, name) => {
  return JSON.stringify(props.state?.[name]);
}) : '';

const parsedArgs = parseLuaObject(cmdArgs) || {};
const jsonedArgs = JSON.stringify(parsedArgs);

console.log('Running command:', command, 'Args:', jsonedArgs);

// const noonce = Math.random().toString();
// { name: 'Noonce', value: noonce },
// process.setStateVariable('UI', 'noonceSent', noonce);

const tags: Tag[] = [
  { name: 'Action', value: 'UIRun' },
  { name: 'Data', value: command },
  { name: 'Args', value: jsonedArgs },
];

props.aoSendMsg(tags);

}


</script>
../lib/ui-base../lib/vue-inside-vue../lib/ui-state-parser../../core/parser