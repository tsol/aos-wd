<template>
      <div ref="divRef" style="height: 50vh; border: 1px solid black; padding-left: 1em;"></div>
</template>

<script lang="ts" setup>
import 'xterm/css/xterm.css';

import { ref, onMounted } from 'vue';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { Readline } from 'xterm-readline';
import { splash } from '@/lib/splash.js';

import { usePersistStore } from '~/store/persist';
import { useAO } from '~/composables/useAO';

const ao = useAO();
const errors = computed(() => ao.errors.value);
const output = computed(() => ao.output.value);

const divRef = ref<HTMLDivElement | null>(null);
const pid = usePersistStore().pid;

const aosPrompt = usePrompt();
const terminal = ref<Terminal | null>(null);
const rl = ref<Readline | null>(null);

const fitAddon = new FitAddon();


// on resize run fitAddon.fit()

onMounted(() => {
  window.addEventListener('resize', () => {
    fitAddon.fit();
  });
});


watch( errors, (newErrors) => {
  if (newErrors.length > 0) {
    outputArray(newErrors);
    ao.flushErrors();
  }
}, { deep: true });

watch( output, (newOutput) => {
  if (terminal.value && newOutput.length > 0) {
    outputArray(newOutput);
    ao.flushOutput();
  }
}, { deep: true });


watch( [() => pid, divRef], () => {
  if (pid && divRef.value) {
    console.log('creating Terminal instance PID:', pid);
    createTerminal();
  }
}, { immediate: true });


function outputArray(strings: string[]) {
  if (! terminal.value)
    throw new Error('Terminal not created');
  terminal.value.writeln('');
  terminal.value.writeln(strings.join('\r\n'));
  terminal.value.write(aosPrompt.value);
}

function createTerminal() {
  // Create a new terminal instance
  terminal.value = new Terminal({
    theme: {
      background: '#FFF',
      foreground: '#191A19',
      selectionForeground: '#FFF',
      selectionBackground: '#191A19',

      cursor: 'black',
      
    },
    cursorBlink: true,
    cursorStyle: 'block',
    
  });

  rl.value = new Readline();

  if (! terminal.value || ! rl.value)
    throw new Error('Terminal or Readline not created');
  
  if (! divRef.value)
    throw new Error('divRef not created');

  terminal.value.loadAddon(fitAddon);

  terminal.value.loadAddon(rl.value);
  terminal.value.open(divRef.value);

  terminal.value.resize(terminal.value.cols, 120);
  terminal.value.focus();

  terminal.value.writeln(splash() + '\r\n');

  rl.value.setCheckHandler((text) => {
    let trimmedText = text.trimEnd();
    if (trimmedText.endsWith('&&')) {
      return false;
    }
    return true;
  });

  fitAddon.fit();

  readLine();
};

function readLine() {
  rl.value?.read(aosPrompt.value).then(
    (res) => {
      useAO().command(res);
      setTimeout(readLine);
    }
  );
}


function clear() {
  terminal.value?.reset();
  terminal.value?.write('aos> ');
}


</script>
