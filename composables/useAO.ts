import { loadBlueprint } from "~/lib/ao/commands/blueprints";
import { evaluate } from "~/lib/ao/evaluate";
import { live } from "~/lib/ao/live";
import { findPid } from "~/lib/ao/query";
import { register } from "~/lib/ao/register";
import { usePersistStore } from "~/store/persist";
import { ref } from 'vue';

console.log('useAO: init');

const pid = computed(() => usePersistStore().pid);

const interval = ref<NodeJS.Timeout | null>(null);
const errors = ref<string[]>([]);

const listeners = ref<((lines: string[]) => void)[]>([]);

export const useAO = () => {


  function addListener(listener: (lines: string[]) => void) {
    listeners.value.push(listener);
  }

  function removeListener(listener: (lines: string[]) => void) {
    listeners.value = listeners.value.filter(l => l !== listener);
  }

  function broadcast(lines: string[]) {
    listeners.value.forEach(l => l(lines));
  }

  async function command(text: string) {

    const loadBlueprintExp = /\.load-blueprint\s+(\w*)/;

    if (loadBlueprintExp.test(text)) {
      const bpName = text.match(/\.load-blueprint\s+(\w*)/)?.[1];
      if (!bpName) throw new Error('No blueprint name provided');
      text = await loadBlueprint(bpName);
      // output.value.push('loading ' + bpName + '...');
      broadcast(['loading ' + bpName + '...']);
    }

    if (pid.value?.length !== 43) {
      errors.value.push('Connect to a process to get started.');
      return;
    }


    try {
      const result = await evaluate(pid.value, text);
      // output.value = [ ...output.value, ...String(result).split('\n') ];
      broadcast(String(result).split('\n'));
    } catch (e: any) {
      errors.value.push(e.message);
    }

  }


  async function doLive() {
    // let liveMsg = '';
    
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
      const msgs = await live(pid.value);

      // if (msg !== null && msg !== liveMsg) {
      //   liveMsg = msg;
      if (msgs?.length) broadcast(msgs);
      // }

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
      await doLive();
    } catch (e: any) {
      errors.value.push(e.message);
    }
  }

  async function connect(pidOrName: string, setName?: string) {
    // let result = prompt('PID or NAME: ');
    let pid = pidOrName
    let name = setName;

    if (pidOrName.length !== 43) {

      let address = await (window as any).arweaveWallet.getActiveAddress();
      const _pid = await findPid(pidOrName, address);

      if (_pid.length !== 43) {
        errors.value.push('Could not find Process!');
        return;
      }

      pid = _pid;
    }

    if (!name) name = pidOrName;

    usePersistStore().setCurrent({ pid, name });
    await doLive();
  }

  async function disconnect() {
    usePersistStore().setCurrent(undefined);
    if (!interval.value) return;
    clearInterval(interval.value);
    interval.value = null;
  }

  function flushErrors() {
    errors.value = [];
  }

  const online = computed(() => pid.value?.length === 43 && interval.value !== null);

  watch(() => pid.value, (pid) => {

    if (pid?.length !== 43) {
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

  return { pid, online, errors, addListener, removeListener, command, newProcess, connect, disconnect, flushErrors };

}
