
export const useProcess = (pid: string) => {

  const processes = useProcesses();
  const found = processes.running.value.find(p => p.pid === pid);
  if (!found) throw new Error('Process not found');

  function command(text: string, silent?: boolean) {
    if (!silent)
      processes.broadcast(pid, [{ type: 'internal', data: text, tags: [] }], 'console');
    return processes.command(pid, text);
  }

  function rundry(toPid: string, tags: Tag[], data = "") {
    processes.broadcast(pid, [{ type: 'internal', data, tags }], 'console');
    return processes.rundry(pid, toPid, tags, data);
  }

  return {
    command,
    rundry,
    addListener: (client: BrodcastClient) => processes.addListener(pid, client),
    removeListener: (listener: BrodcastClient['handler']) => processes.removeListener(pid, listener),
    broadcast: (lines: BrodcastMsg[], target?: BrodcastClient['type']) => processes.broadcast(pid, lines, target),
  }

}
