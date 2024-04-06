import { defineStore } from 'pinia'
import { createPersistedState } from 'pinia-plugin-persistedstate';

type Process = {
  pid: string;
  name: string
}

export const usePersistStore = defineStore('persist', {
  state: () => ({
    current: { pid: '', name: 'default' } as Process,
    processes: [] as Process[],
    cursor: {} as Record<string, string>
  }),
  getters: {
    pid(state) {
      if (! useWallet().connected) return '';
      return state.current.pid;
    },
    getProcesses(state) {
      return state.processes;
    },
    getAllCursors(state) {
      return state.cursor;
    },
    getCurrentCursor(state) {
      return state.cursor[ state.current.pid ] || '';
    }
  },
  actions: {
    updateCursor(pid: string, cursor: string) {
      this.cursor[pid] = cursor;
    },
    setCurrent(process: Process) {
      this.current = process;
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
