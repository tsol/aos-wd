
import { usePersistStore, type StoredSnippet, type StoredWidget } from "~/store/persist";


export function useProcess<STATE>(pid: string) {

  const processes = useProcesses();
  const persistStore = usePersistStore();
  
  const process = persistStore.processes.find(
    (process) => process.pid === pid
  );

  const state = computed<STATE>({
    get: () => process?.state,
    set: (value) => {
      if (process) {
        process.state = value;
      }
    }
  });
  
  if (! state.value ) {
    state.value = {} as STATE;
  }

  const name = computed(() => process?.name || '');

  const widgets = computed(() => {
    return process?.widgets || [];
  });


  function command(text: string, silent?: boolean, tags?: Tag[]) {
    if (!silent)
      processes.broadcast(pid, [{ type: 'internal', data: text }], 'Console');
    return processes.command(pid, text, tags);
  }

  function rundry(toPid: string, data = "") {
    processes.broadcast(pid, [{ type: 'dryrun', data }], 'Console');
    return processes.rundry(pid, toPid, data);
  }

  function addWidget(name: string) {
    persistStore.enableWidget(pid, name);
  }

  function removeWidget(name: string) {
    persistStore.disableWidget(pid, name);
  }

  function replaceWidgets(widgets: StoredWidget[]) {
    persistStore.replaceWidgets(pid, widgets);
  }
 
  function setStateVariable(widget: string, key: string, value: any) {
    // console.log('setting state variable', key, value);

    const newState = { ...state.value, [widget]: {
      ... ((state.value as any)[widget] || {}),
      [key]: value }
    };
    state.value = newState;
  }

  function addSnippet(widgetName: string, snippet: StoredSnippet) {
    const w = widgets.value.find(w => w.name === widgetName);
    if (!w) return;
    w.snippets = w.snippets || [];

    const exists = w.snippets.find(s => s.name === snippet.name);
    if (exists) return;

    w.snippets = [...w.snippets, snippet];
  }

  function removeSnippet(widgetName: string, snippetName: string) {
    const w = widgets.value.find(w => w.name === widgetName);
    if (!w) return;
    if (!w.snippets) return;
    w.snippets = w.snippets.filter(s => s.name !== snippetName);
  }


  return {
    name,
    process,
    widgets,
    state,
    setStateVariable,
    replaceWidgets,
    addWidget,
    removeWidget,
    command,
    rundry,
    addListener: (client: BrodcastClient) => processes.addListener(pid, client),
    removeListener: (listener: BrodcastClient['handler']) => processes.removeListener(pid, listener),
    broadcast: (lines: BrodcastMsg[], target?: BrodcastClient['client']) => processes.broadcast(pid, lines, target),
    getListenerNames: () => processes.getListenerNames(pid),
    addSnippet,
    removeSnippet,
  }

}
