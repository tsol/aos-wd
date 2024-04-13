
import { usePersistStore, type StoredWidget } from "~/store/persist";

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
  
  const name = computed(() => process?.name || '');

  const widgets = computed(() => {
    return process?.widgets || [];
  });

  function command(text: string, silent?: boolean) {
    if (!silent)
      processes.broadcast(pid, [{ type: 'internal', data: text, tags: [] }], 'Console');
    return processes.command(pid, text);
  }

  function rundry(toPid: string, tags: Tag[], data = "") {
    processes.broadcast(pid, [{ type: 'dryrun', data, tags }], 'Console');
    return processes.rundry(pid, toPid, tags, data);
  }

  function addWidget(widget: StoredWidget) {
    persistStore.enableWidget(pid, widget);
  }

  function removeWidget(name: string) {
    persistStore.disableWidget(pid, name);
  }

  function replaceWidgets(widgets: StoredWidget[]) {
    persistStore.replaceWidgets(pid, widgets);
  }
 
  function setStateVariable(widget: string, key: string, value: any) {
    // console.log('setting state variable', key, value);

    const newState = { ...state.value, [widget]: { [key]: value } };
    state.value = newState;
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
  }

}
