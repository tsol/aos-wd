<template>
  <div>
      <div ref="divRef" style="height: 50vh; border: 1px solid black; padding-left: 1em;">
      </div>
      <v-alert
        v-if="errors.length > 0"
        type="error"
        elevation="2"
        class="mt-2"
        clearable
        colored-border
        dense
        outlined
        v-for="error in errors"
        :key="error"
      >
        {{ error }}
      </v-alert>
  </div>
</template>

<script lang="ts" setup>
import 'xterm/css/xterm.css';

import { ref, onMounted } from 'vue';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { Readline } from 'xterm-readline';
import { splash } from '@/lib/ao/splash.js';

import { useAO, type BrodcastMsg } from '~/composables/useAO';

const ao = useAO();
const errors = computed(() => ao.errors.value);

ao.addListener(listen);


const divRef = ref<HTMLDivElement | null>(null);
const pid = computed(() => ao.pid.value);

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


function listen(text: BrodcastMsg[]) {
  if (terminal.value) {
    outputArray(text.map((msg) => msg.data));
  }
}

watch( [pid, divRef], () => {

  if (!pid.value && divRef.value && terminal.value) {
    outputArray(['Connect to a process.']);
    return;
  }

  if (pid.value && divRef.value) {
    console.log('creating Terminal instance PID:', pid);
    createTerminal();
  }
}, { immediate: true, deep: true});


function outputArray(strings: string[]) {
  if (! terminal.value)
    throw new Error('Terminal not created');
  const splitted = strings.reduce((acc, str) => {
    return acc.concat(str.split('\n'));
  }, [] as string[]);

  terminal.value.writeln('');
  terminal.value.writeln(splitted.join('\r\n'));
  terminal.value.write(aosPrompt.value);
}

function createTerminal() {
  
  if (terminal.value) {
    // fitAddon.fit();
    // readLine();
    outputArray(['Connected.']);
    return;
  }

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

onUnmounted(() => {
  ao.removeListener(listen);
});

function clear() {
  terminal.value?.reset();
  terminal.value?.write('aos> ');
}


</script>
