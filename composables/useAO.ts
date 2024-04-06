import { loadBlueprint } from "~/lib/commands/blueprints";
import { evaluate } from "~/lib/evaluate";
import { live } from "~/lib/live";
import { findPid } from "~/lib/query";
import { register } from "~/lib/register";
import { usePersistStore } from "~/store/persist";
import { ref } from 'vue';

console.log('useAO: init');

const pid = computed(() => usePersistStore().pid);

const interval = ref<NodeJS.Timeout | null>(null);
const errors = ref<string[]>([]);
const output = ref<string[]>([]);

export const useAO = () => {

  async function command(text: string) {

    const loadBlueprintExp = /\.load-blueprint\s+(\w*)/;

    if (loadBlueprintExp.test(text)) {
      const bpName = text.match(/\.load-blueprint\s+(\w*)/)?.[1];
      if (!bpName) throw new Error('No blueprint name provided');
      text = await loadBlueprint(bpName);
      output.value.push('loading ' + bpName + '...');
    }

    if (pid.value.length !== 43) {
      errors.value.push('Connect to a process to get started.');
      return;
    }


    try {
      const result = await evaluate(pid.value, text);
      output.value = [ ...output.value, ...String(result).split('\n') ];
    } catch (e: any) {
      errors.value.push(e.message);
    }

  }


  async function doLive() {
    let liveMsg = '';
    console.log('starting live');
    if (interval.value) {
      console.log('clearing interval');
      clearInterval(interval.value);
      interval.value = null;
    }
    interval.value = setInterval(async () => {
      if (!pid.value) {
        console.log('no pid');
        return;
      }
      const msg = await live(pid.value);
      if (msg !== null && msg !== liveMsg) {
        liveMsg = msg;
        liveMsg.split('\n').map((m) => output.value.push(m));
      }
    }, 3000);
  }

  async function newProcess(name: string) {
    if (name.length === 0) {
      errors.value.push('Name is required');
      return;
    }
    // if (feed.value) {
    //   terminal.value?.writeln('Status: Connecting to ao...');
    // }
    try {
      const pid = await register(name);
      usePersistStore().setCurrent({ pid, name });
      doLive();
    } catch (e: any) {
      errors.value.push(e.message);
    }
  }

  async function connect(pidOrName: string) {
    // let result = prompt('PID or NAME: ');
    let pid = pidOrName

    if (pidOrName.length !== 43) {

      let address = await (window as any).arweaveWallet.getActiveAddress();
      const _pid = await findPid(pidOrName, address);

      if (_pid.length !== 43) {
        errors.value.push('Could not find Process!');
        return;
      }

      pid = _pid;
    }

    usePersistStore().setCurrent({ pid, name: pidOrName });
    doLive();
  }

  async function disconnect() {
    usePersistStore().setCurrent({ pid: '', name: 'default' });
    if (!interval.value) return;
    clearInterval(interval.value);
    interval.value = null;
  }

  function flushOutput() {
    output.value = [];
  }

  function flushErrors() {
    errors.value = [];
  }

  const online = computed(() => pid.value.length === 43 && interval.value !== null);

  watch ( () => pid.value, (pid) => {

    if (pid.length !== 43) {
      if (interval.value) {
        clearInterval(interval.value);
        interval.value = null;
      }
    } else {
      if (!interval.value) {
        doLive();
      }
    }

  }, { immediate: true });

  return { online, errors, output, command, newProcess, connect, disconnect, flushOutput, flushErrors };

}
