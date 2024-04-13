import { loadBlueprint } from "~/lib/ao/commands/blueprints";
import { evaluate } from "~/lib/ao/evaluate";
import { live } from "~/lib/ao/live";
import { findPid } from "~/lib/ao/query";
import { register } from "~/lib/ao/register";
import { usePersistStore } from "~/store/persist";
import { ref } from 'vue';
import { dryrun } from "@permaweb/aoconnect";

console.log('useProcesses: init');

export type Tag = { name: string, value: string };

export type BrodcastMsg = {
  tags: Tag[],
  data: string,
  type: 'dryrun' | 'live' | 'evaluate' | 'internal'
  forClient?: string;
  fromClient?: string;
};

export type BrodcastClient = {
  client: string;
  handler: (lines: BrodcastMsg[]) => void;
}

type RunningProcess = {
  pid: string;
  interval: NodeJS.Timeout | null;
  listeners: BrodcastClient[];
}

const running = ref<RunningProcess[]>([]);

export const useProcesses = () => {

  const errors = ref<string[]>([]);
  
  function getRunning(pid: string) {
    return running.value.find(r => r.pid === pid);
  }

  function addListener(pid: string, client: BrodcastClient) {
    const { handler: listener } = client;
    removeListener(pid, listener);
    getRunning(pid)?.listeners.push(client);
  }

  function removeListener(pid: string, listener: BrodcastClient['handler']) {
    // listeners.value = listeners.value.filter(l => l !== listener);
    const runningProcess = getRunning(pid);
    if (!runningProcess) return;
    runningProcess.listeners = runningProcess.listeners.filter(l => l.handler !== listener);
  }

  function broadcast(pid: string, lines: BrodcastMsg[], target?: BrodcastClient['client']) {
    const runningProcess = getRunning(pid);
    if (!runningProcess) return;

    if (target) {
      const targets = runningProcess.listeners.filter(l => l.client === target);
      targets.forEach(t => t.handler(lines));
      return
    }

    runningProcess.listeners.forEach(l => l.handler(lines));
  }

  function getListenerNames(pid: string) {
    return getRunning(pid)?.listeners.map(l => l.client);
  }

  async function command(pid: string, text: string) {

    const loadBlueprintExp = /\.load-blueprint\s+(\w*)/;

    if (loadBlueprintExp.test(text)) {
      const bpName = text.match(/\.load-blueprint\s+(\w*)/)?.[1];
      if (!bpName) throw new Error('No blueprint name provided');
      text = await loadBlueprint(bpName);
      // output.value.push('loading ' + bpName + '...');
      broadcast(pid, [{ data: 'loading ' + bpName + '...', tags: [], type: 'internal' }]);
    }

    if (pid?.length !== 43) {
      errors.value.push('Connect to a process to get started.');
      return;
    }


    try {
      const result = await evaluate(pid, text);
      // output.value = [ ...output.value, ...String(result).split('\n') ];
      const msgs = String(result).split('\n').map((line) => ({ data: line, tags: [], type: 'evaluate' } as BrodcastMsg));
      broadcast(pid, msgs);
    } catch (e: any) {
      errors.value.push(e.message);
    }

  }


  async function startProcess(pid: string, name?: string) {
 
    console.log('starting live ', pid);
    let runningProcess = getRunning(pid);

    if (runningProcess) {
      console.log('already running');
      return;
    }

    usePersistStore().addProcess({ pid, name: name || pid});

    running.value.push({ pid, interval: null, listeners: [] });
    runningProcess = getRunning(pid);

    if (!runningProcess) throw new Error('Could not start process');

    usePersistStore().setRunning(pid, true);

    runningProcess.interval = setInterval(async () => {
      if (!pid) {
        console.log('no pid');
        return;
      }
      const msgs = await live(pid);
  
      const bmsgs = msgs?.map((line) => ({ data: line, tags: [], type: 'live' } as BrodcastMsg));

      if (bmsgs?.length) broadcast(pid, bmsgs);

    }, 3000);
  }

  async function newProcess(name: string) {
    if (name.length === 0) {
      errors.value.push('Name is required');
      return;
    }

    try {
      const pid = await register(name);
      await startProcess(pid, name);
    } catch (e: any) {
      errors.value.push(e.message);
    }
  }

  async function rundry(ownerPid: string, toPid: string, tags: Tag[], data = "") {

    const evaluatedTags = tags.map((tag) => {
      const newTag = { ...tag };
      if (tag.value === 'ao.id')
        newTag.value = ownerPid;
      return tag;
    });

    try {

      const result = await dryrun({
        process: toPid,
        Owner: ownerPid,
        tags: evaluatedTags,
        data,
      });
      const forMeLines = result.Messages
        .filter((msg: any) => msg.Target === ownerPid)
        .map((msg: any) => ({ data: msg.Data, tags: msg.Tags, type: 'dryrun' } as BrodcastMsg));

      broadcast(ownerPid, forMeLines);

      return result;

    }
    catch (e: any) {
      errors.value.push(e.message);
      return;
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

    await startProcess(pid, name);
  }

  async function disconnect(pid: string) {
   
    const runningProcess = getRunning(pid);
    if (!runningProcess) return;

    if (runningProcess.interval) {
      clearInterval(runningProcess.interval);
      runningProcess.interval = null;

    }

    running.value = running.value.filter(r => r.pid !== pid);
    usePersistStore().setRunning(pid, false);
  }

  function flushErrors() {
    errors.value = [];
  }


  return { 
    running,
    errors,
    
    broadcast,
    addListener,
    removeListener,
    getListenerNames,

    command,
    rundry,

    newProcess,
  
    connect,
    disconnect,
    flushErrors
  };

}
