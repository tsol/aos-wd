import { defineStore } from 'pinia'
import { createPersistedState } from 'pinia-plugin-persistedstate';

export type Process = {
  pid: string;
  name: string
  isRunning?: boolean;
}

export const usePersistStore = defineStore('persist', {
  state: () => ({
    currentPid: undefined as string | undefined,
    processes: [] as Process[],
    cursor: {} as Record<string, string>
  }),
  getters: {
    getProcesses(state) {
      return state.processes;
    },
    getAllCursors(state) {
      return state.cursor;
    },
    getCurrentProcess(state) {
      const proc = state.processes.find(p => p.pid === state.currentPid);
      return proc;
    }
  },
  actions: {
    setRunning(pid: string, running: boolean) {
      const process = this.processes.find(p => p.pid === pid);
      if (process) {
        process.isRunning = running;
      }
    },
    updateName(pid: string, name: string) {
      const process = this.processes.find(p => p.pid === pid);
      if (process) {
        process.name = name;
        console.log('name was updated for pid:', pid, 'name:', name);
      }
    },
    updateCursor(pid: string, cursor: string) {
      this.cursor[pid] = cursor;
    },
    setCurrentPid(pid: string | undefined) {
      this.currentPid = pid;
      if (pid === undefined) {
        // last running
        const last = this.processes.find(p => p.isRunning);
        if (last) {
          this.currentPid = last.pid;
        }
      }
    },
    addProcess(process: Process) {
      // find if process already exists
      const exists = this.processes.find(p => p.pid === process.pid);
      if (exists) {
        exists.name = process.name;
        return;
      }
      this.processes.push(process);
    }
  },
  persist: {
    storage: window.localStorage,
    key: 'persist',
    afterRestore: (ctx) => {
      console.log(`just restored '${ctx.store.$id}'`)

      const processes = ctx.store.processes as Process[];
      const running = processes.filter(p => p.isRunning);

      // if restored current is not in running, set current as first one
      if (!running.find(p => p.pid === ctx.store.current?.pid)) {
        ctx.store.setCurrentPid(running[0]?.pid);
      }

      running.forEach(p => {
        console.log('PERSIST: connecting to process', p.pid);
        useProcesses().connect(p.pid, p.name);
      });

    }
  },
});
