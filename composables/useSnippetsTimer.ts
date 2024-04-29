import { type StoredSnippet } from "~/store/persist";

type RunningSnippet = {
  snippetId: string;
  interval: NodeJS.Timeout | null;
}

const runningSnippets = ref<RunningSnippet[]>([]);

export const useSnippetsTimer = (process: ReturnType<typeof useProcess>) => {

  const snippets = useSnippets(process);

  function stopSnippetTimer(snippet: StoredSnippet) {
    const snippetId = snippets.snippetID(snippet);
    const found = runningSnippets.value.find((s) => s.snippetId === snippetId);
    if (found?.interval) {
      clearInterval(found.interval);
      runningSnippets.value = runningSnippets.value.filter((s) => s.snippetId !== snippetId);
    }
  }

  function startSnippetTimer(snippet: StoredSnippet, milliseconds?: number) {
    
    const snippetId = snippets.snippetID(snippet);

    const foundRunning = runningSnippets.value.find((s) => s.snippetId === snippetId);
    if (foundRunning) return 'Already running';

    const findWidget = process.widgets.value.find((w) => w.name === snippet.widgetName);
    const foundSnippet = findWidget?.snippets?.find((s) => s.name === snippet.name);
     
    if (milliseconds && foundSnippet) {
      foundSnippet.runInterval = milliseconds;
    }

    if (!foundSnippet || !foundSnippet.runInterval || !(foundSnippet?.runInterval > 0))
      return 'Invalid snippet';

    const interval = setInterval(() => {

      const findWidget = process.widgets.value.find((w) => w.name === snippet.widgetName);
      const findSnippet = findWidget?.snippets?.find((s) => s.name === snippet.name);
      if (findSnippet) {
        snippets.runSnippet(findSnippet);
        return;
      }

      console.error('Snippet not found:', snippet.name);
      stopSnippetTimer(snippet);

    }, snippet.runInterval);

    runningSnippets.value.push({ snippetId, interval });
    return undefined;
  }

  function onUnmounted() {
    runningSnippets.value.forEach((snippet) => {
      if (snippet.interval) {
        clearInterval(snippet.interval);
      }
    });
  }

  return {
    onUnmounted,
    startSnippetTimer,
    stopSnippetTimer,
  }

}
