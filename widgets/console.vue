<template>
  <div>
    <div v-if="process.process" class="d-flex justify-space-between mb-2">
      <v-text-field v-model="process.process.regexFilter" label="Live filter regex" density="compact"></v-text-field>
      <v-checkbox v-model="process.process.substPIDs" label="PID/Name"></v-checkbox>
      <v-checkbox v-model="process.process.disableLive" label="Stop Live"></v-checkbox>
    </div>
    <div ref="divRef" style="height: 50vh;">
    </div>
  </div>
</template>

<script lang="ts" setup>
import 'xterm/css/xterm.css';

import { ref, onMounted } from 'vue';
import { Terminal } from '@xterm/xterm';
import { FitAddon } from '@xterm/addon-fit';
import { Readline } from 'xterm-readline';
import { splash } from '@/lib/ao/splash.js';

import { type BrodcastMsg, useProcesses } from '~/composables/useProcesses';
import { useProcess } from '~/composables/useProcess';
import { usePersistStore } from '~/store/persist';
import { shortenCutMiddle } from '~/lib/utils';

const props = defineProps<{
  pid: string;
}>();

const persist = usePersistStore();

const process = useProcess(props.pid);
process.addListener({ client: 'Console', handler: listen });


const divRef = ref<HTMLDivElement | null>(null);

// const currentFilter = ref<string>('');
// const disableLive = ref(false);
// const substitudePids = ref(false);

const aosPrompt = usePrompt();
const terminal = ref<Terminal | null>(null);
const rl = ref<Readline | null>(null);
const currentInput = ref<string>('');

const fitAddon = new FitAddon();


const computedProcesses = computed(() => persist.processes.map((p) =>
  ({ pid: p.pid, name: p.name, short: shortenCutMiddle(p.pid, 9) })));

onMounted(() => {
  window.addEventListener('resize', () => {
    fitAddon.fit();
  });
});

function listen(text: BrodcastMsg[]) {
  if (terminal.value) {

    const res = [] as string[];

    text.forEach((msg) => {
      if (process.process?.disableLive && msg.type === 'live') return;
      const lines = msg.data.split(/\r?\n/);
      res.push(...lines);
    });

    const filtered = res.filter((msg) => {
      if (!process.process?.regexFilter) return true;
      return msg.match(new RegExp(process.process?.regexFilter, 'i'));
    });

    if (process.process?.substPIDs) {

      //  New Message From RF1...D4c: Action = Attack-Failed
      // cover this short version also

      filtered.forEach((msg, i) => {
        computedProcesses.value.forEach((p) => {
          if (msg.includes(p.pid)) {
            filtered[i] = 
              msg.replace(p.pid, p.name)
                .replace(p.short, p.name);
          }
        });
      });
    }

    outputArray(filtered);
  }
}

watch([() => props.pid, divRef], () => {

  if (!props.pid && divRef.value && terminal.value) {
    outputArray(['Connect to a process.']);
    return;
  }

  if (props.pid && divRef.value) {
    // console.log('creating Terminal instance PID:', props.pid);
    createTerminal();
  }
}, { immediate: true, deep: true });


function outputArray(strings: string[]) {
  if (!terminal.value)
    throw new Error('Terminal not created');

  const splitted = strings.reduce((acc, str) => {
    return acc.concat(str.split('\n'));
  }, [] as string[]);

  if (splitted.length === 0) return;

  terminal.value.writeln('');
  terminal.value.writeln(splitted.join('\r\n'));
  terminal.value.write(aosPrompt.value + currentInput.value);

  fitAddon.fit();
}

function createTerminal() {

  if (terminal.value) {

    outputArray(['Connected.']);
    return;
  }

  terminal.value = new Terminal({
    theme: persist.theme === 'light' ?{
      background: '#FFF',
      foreground: '#191A19',
      selectionForeground: '#FFF',
      selectionBackground: '#191A19',

      cursor: 'black',

    } : {
      background:'#2d2d2d',
      foreground: '#FFF',
      selectionForeground: '#444',
      selectionBackground: '#191A19',

      cursor: 'white',
    },
    cursorBlink: true,
    cursorStyle: 'block',

  });

  rl.value = new Readline();

  if (!terminal.value || !rl.value)
    throw new Error('Terminal or Readline not created');

  if (!divRef.value)
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

  terminal.value.onKey(({ key }) => {
    if (key === '\u007F') {  // Backspace key
      currentInput.value = currentInput.value.slice(0, -1);
    } else {
      currentInput.value += key;
    }
  });

  setTimeout(readLine);
};

function readLine() {
  currentInput.value = '';

  rl.value?.read(aosPrompt.value).then(
    (res) => {
      process.command(res, true);
      setTimeout(readLine);
    }
  );
}

onUnmounted(() => {
  process.removeListener(listen);
});


</script>


~/composables/useProcesses