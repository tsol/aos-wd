import { defineStore } from 'pinia'
import { createPersistedState } from 'pinia-plugin-persistedstate';
import { createWidget } from '~/widgets';

export type StoredSnippet = {
  name: string;
  data: string;
  
  pid?: string;
  tags?: Tag[];
}

export type StoredWidget = {
  name: string;
  column?: number;
  colWidth?: number;
  snippets?: StoredSnippet[];
}

export type Process = {
  pid: string;
  name: string
  isRunning?: boolean;
  widgets?: StoredWidget[];
  state?: any;
}

export const usePersistStore = defineStore('persist', {
  state: () => ({
    currentPid: undefined as string | undefined,
    processes: [] as Process[],
    cursor: {} as Record<string, string | undefined>
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
    updateProcessDefaultWidgets(pid: string) {
      const process = this.processes.find(p => p.pid === pid);
      if (!process) throw new Error('process not found');

      if ((!process.widgets || process.widgets.length === 0)) {
        const console = createWidget('Console');
        if (console) 
          process.widgets = [console];
      }

      if (!process.state) {
        process.state = {};
      }

    },
    enableWidget(pid: string, name: string) {
      const process = this.processes.find(p => p.pid === pid);
      if (!process) return;

      process.widgets = process.widgets || [];
      const exists = process.widgets.find(widget => widget.name === name);
      if (exists) {
        // make enabled = true later
        return;
      } else {
        const w = createWidget(name);
        if (!w) {
          console.error('widget not found:', name);
          return;
        }
        process.widgets.unshift(w);
      }

    },
    disableWidget(pid: string, name: string) {
      const process = this.processes.find(p => p.pid === pid);
      if (process) {
        process.widgets = (process.widgets || []).filter(w => w.name !== name);
      }
    },
    replaceWidgets(pid: string, widgets: StoredWidget[]) {
      const process = this.processes.find(p => p.pid === pid);
      if (process) {
        process.widgets = widgets;
      }
    },
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
    updateCursor(pid: string, cursor: string | undefined) {
      this.cursor[pid] = cursor;
    },
    setCurrentPid(pid: string | undefined) {
      this.currentPid = pid;

      if (pid === undefined) {
        const last = this.processes.find(p => p.isRunning);
        if (last) {
          this.currentPid = last.pid;
        }
      }

    },
    addProcess(process: Process) {
      const exists = this.processes.find(p => p.pid === process.pid);
      if (exists) {
        exists.name = process.name;
        return;
      }
      this.processes.push(process);
    },
    removeProcess(pid: string) {
      this.processes = this.processes.filter(p => p.pid !== pid);
      this.cursor[pid] = undefined;
    },
  },
  persist: {
    storage: window.localStorage,
    key: 'persist',
    afterRestore: (ctx) => {
      // console.log(`PERSIST: restored '${ctx.store.$id}'`)

      const processes = ctx.store.processes as Process[];
      const running = processes.filter(p => p.isRunning);

      if (!running.find(p => p.pid === ctx.store.current?.pid)) {
        ctx.store.setCurrentPid(running[0]?.pid);
      }

      running.forEach(p => {
        // console.log('PERSIST: connecting to process', p.pid);
        useProcesses().connect(p.pid, p.name);
      });

    }
  },
});
