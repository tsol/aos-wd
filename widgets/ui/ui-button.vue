<template>
  <v-btn
    v-bind="$attrs"
    @click="onClick"
    :disabled="uiLoading || !isValid"
  >
    <!-- pass through all slots -->
    <slot v-for="(_, name) in $slots" :name="name" :slot="name" />
  </v-btn>
</template>

<script setup lang="ts">
import { parseLuaObject } from '~/lib/parser';
import type { State } from './ui';

// <!--<ui-button label="Login" ui-valid="name" ui-run="cmdLogin({ name = $name })" />-->

const props = defineProps<{
  uiValid?: string;
  uiRun: string;
  uiLoading?: boolean;

  inputsValidity?: Record<string, boolean>
  process: ReturnType<typeof useProcess<any>>;
  state?: State['ui'],
  
}>();

const myInputs = props.uiValid?.split(/[\s,]+/) || [];

// function isValid() {
//   return myInputs.every((input) => props.inputsValidity?.[input]);
// }

const isValid = computed(() => myInputs.every((input) => props.inputsValidity?.[input]));

function onClick() {

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

  parsedArgs['pid'] = props.process.process?.pid;
  const jsonedArgs = JSON.stringify(parsedArgs);

  console.log('Running command:', command, 'Args:', jsonedArgs);
 
  const noonce = Math.random().toString();
 
  const tags: Tag[] = [
    { name: 'Action', value: 'UIRun' },
    { name: 'Args', value: jsonedArgs },
    { name: 'Noonce', value: noonce },
  ];

  props.process.command(command, false, tags);
  props.process.setStateVariable('UI', 'noonceSent', noonce);

}

</script>
