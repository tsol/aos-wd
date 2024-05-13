import { loadBlueprint } from "~/lib/ao/commands/blueprints";
import { evaluate } from "~/lib/ao/evaluate";
import { live, textFromMsg, type Edge } from "~/lib/ao/live";
import { findPid, processesList } from "~/lib/ao/query";
import { register } from "~/lib/ao/register";
import { usePersistStore } from "~/store/persist";
import { ref } from 'vue';
import { dryrun } from "@permaweb/aoconnect";
import { shortenCutMiddle } from "~/lib/utils";
import { startMonitor, stopMonitor } from "~/lib/ao/cron";

console.log('useProcesses: init');

export type Tag = { name: string, value: string };

export type BrodcastMsg = {
  msg?: Edge,
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

  const persist = usePersistStore()

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

  async function command(pid: string, text: string, tags?: Tag[]) {

    const loadBlueprintExp = /\.load-blueprint\s+(\w*)/;

    if (loadBlueprintExp.test(text)) {
      const bpName = text.match(/\.load-blueprint\s+(\w*)/)?.[1];
      if (!bpName) throw new Error('No blueprint name provided');
      text = await loadBlueprint(bpName);
      broadcast(pid, [{ data: 'loading ' + bpName + '...', type: 'internal' }]);
    }

    if (pid?.length !== 43) {
      useToast().error('Connect to a process to get started.');
      return;
    }


    try {
      const result = await evaluate(pid, text, tags);
      // if (result === undefined) {
      //   broadcast(pid, [{ data: "undefined", type: 'evaluate' }]);
      // }
      const msgs = [{ data: String(result), type: 'evaluate' } as BrodcastMsg];
      broadcast(pid, msgs);

    } catch (e: any) {
      console.error(e);
      useToast().error(e.message);
    }

  }

  async function startProcess(pid: string, name?: string) {

    console.log('starting live ', pid);
    let runningProcess = getRunning(pid);

    if (runningProcess) {
      console.log('already running');
      return;
    }

    persist.addProcess({ pid, name: name || pid });

    running.value.push({ pid, interval: null, listeners: [] });
    runningProcess = getRunning(pid);

    if (!runningProcess) throw new Error('Could not start process');

    persist.setRunning(pid, true);

    runningProcess.interval = setInterval(async () => {
      if (!pid) {
        console.log('no pid');
        return;
      }

      const cursor = toRef(persist.getAllCursors[pid]);
      const msgs = await live(pid, cursor);
      persist.updateCursor(pid, cursor.value);

      try {
        const bmsgs = msgs?.map((msg) => {
          const text = textFromMsg(msg);
          const bm = {
            data: text ? text.trim() : '',
            msg: msg,
            type: 'live'
          } as BrodcastMsg;

          return bm;
        });

        if (bmsgs?.length) broadcast(pid, bmsgs);

      }
      catch (e: any) {
        console.log('---------------------------------------------');
        console.error(e);
        console.log('msgs:', msgs);
      }


    }, 3000);
  }

  async function newProcess(name: string, cronMode?: string) {
    if (name.length === 0) {
      console.error('Name is required!');
      return;
    }

    try {
      const pid = await register(name, cronMode);
      await startProcess(pid, name);
      return pid;
    } catch (e: any) {
      useToast().error(e.message);
    }
    return undefined
  }

  async function rundry(ownerPid: string, toPid: string, data = "", tags: Tag[] = []) {

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
        .map((msg: any) => ({ data: msg.Data, msg, type: 'dryrun' } as BrodcastMsg));

      broadcast(ownerPid, forMeLines);

      return result;

    }
    catch (e: any) {
      useToast().error(e.message);
      return;
    }

  }


  async function queryAllProcessesWithNames() {
    const address = await (window as any).arweaveWallet.getActiveAddress();
    if (!address) {
      useToast().error('No wallet connected!');
      return [];
    }
    const list = await processesList(address);
    return list;
  }

  async function connect(pidOrName: string, setName?: string) {

    try {
      let pid = pidOrName
      let name = setName;

      if (pidOrName.length !== 43) {

        let address = await (window as any).arweaveWallet.getActiveAddress();
        const _pid = await findPid(pidOrName, address);

        if (_pid?.length !== 43) {
          useToast().error('Could not find Process!');
          useToast().error(`Could not find Process! ${pidOrName}`);
          return;
        }

        pid = _pid;
      }

      if (!name) name = pidOrName;

      await startProcess(pid, name);
    }
    catch (e: any) {
      useToast().error('Error connecting to a process');
    }
  }

  async function disconnect(pid: string) {

    const runningProcess = getRunning(pid);
    if (!runningProcess) return;

    if (runningProcess.interval) {
      clearInterval(runningProcess.interval);
      runningProcess.interval = null;

    }

    running.value = running.value.filter(r => r.pid !== pid);
    persist.setRunning(pid, false);

    if (pid === persist.currentPid) {
      persist.setCurrentPid(undefined);
    }

  }


  function getName(pid: string) {
    return persist.getProcesses.find(p => p.pid === pid)?.name || shortenCutMiddle(pid, 9);
  }

  function setMonitoredFlag(pid: string, monitored: boolean) {
    const process = persist.getProcesses.find(p => p.pid === pid);
    if (process) {
      process.monitored = monitored;
    }
  }

  async function monitor(pid: string) {
    try {
      const res = await startMonitor(pid);
      setMonitoredFlag(pid, true);
    } catch (e: any) {
      useToast().error(e.message);
      if (e.message?.includes('already')) {
        setMonitoredFlag(pid, true);
      }
    }
  }



  async function unmonitor(pid: string) {
    try {
      const res = await stopMonitor(pid);
      setMonitoredFlag(pid, false);
    }
    catch (e: any) {
      useToast().error(e.message);
      if (e.message?.includes('already')) {
        setMonitoredFlag(pid, false);
      }
    }

  }


  return {
    running,

    getName,

    broadcast,
    addListener,
    removeListener,
    getListenerNames,

    command,
    rundry,

    newProcess,

    connect,
    disconnect,

    monitor,
    unmonitor,

    queryAllProcessesWithNames,
  };

}
