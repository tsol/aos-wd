import { defineStore } from 'pinia'
import { createPersistedState } from 'pinia-plugin-persistedstate';

export type Process = {
  pid: string;
  name: string
}

export const usePersistStore = defineStore('persist', {
  state: () => ({
    current: undefined as Process | undefined,
    processes: [] as Process[],
    cursor: {} as Record<string, string>
  }),
  getters: {
    pid(state) {
      if (! useWallet().connected) return '';
      return state.current?.pid;
    },
    getProcesses(state) {
      return state.processes;
    },
    getAllCursors(state) {
      return state.cursor;
    },
    getCurrentCursor(state) {
      if (! state.current?.pid) return '';
      return state.cursor[ state.current.pid ] || '';
    }
  },
  actions: {
    updateCurrentName(name: string) {
      if (!this.current) return;
      this.current.name = name;

      const process = this.processes.find(p => p.pid === this.current?.pid);
      if (process) {
        process.name = name;
      }
    },
    updateCursor(pid: string, cursor: string) {
      this.cursor[pid] = cursor;
    },
    setCurrent(process: Process | undefined) {
      this.current = process;
      if (!process) return;
      this.addProcess(process);
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
    }
  },
});
