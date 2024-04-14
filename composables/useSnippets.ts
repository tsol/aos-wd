import { extractTemplateVariables } from "~/lib/utils";
import type { StoredSnippet } from "~/store/persist";

export const useSnippets = (process: ReturnType<typeof useProcess>) => {

  const snippetLoading = reactive<Record<string, boolean>>({});
  const snippetMenu = reactive<Record<string, boolean>>({});

  function evaluateSnippetTemplate(snippet: StoredSnippet) {
    const data = snippet.data;
    if (!data) return undefined;
  
    const varsInTemplate = extractTemplateVariables(data);
    if (!varsInTemplate.length) return data;
  
    const state = process.state.value as any;
    if (!state) return error('No state');
  
    const passed = varsInTemplate.every((variable) => {
      const res = variable in state && !!state[variable];
      if (! res) error(`Variable ${variable} not found in state`);
      return res;
    });
  
    if (!passed) return undefined;
  
    function error(msg?: string) {
      console.error(`Error evaluating snippet data for ${snippet.name}`);
      console.log('Error:', msg);
      console.log('State:', state);
      snippetMenu[snippet.name] = true;
      return undefined;
    }
  
    const evaluated = varsInTemplate.reduce((acc, variable) => {
      if (variable in state) {
        return acc.replace(new RegExp(`{{${variable}}}`, 'g'), `${String(state[variable])}`);
      }
      return acc;
    }, data);
  
    return evaluated;
  }
  
  
  async function runSnippet(snippet: StoredSnippet) {
  
    if (snippet.pid && snippet.tags) {
      snippetLoading[snippet.name] = true;
      const data = evaluateSnippetTemplate(snippet);
      const res = await process.rundry(snippet.pid, snippet.tags, data);
      snippetLoading[snippet.name] = false;
      return res;
    }
  
    if (!snippet.data) return undefined;
  
    const data = evaluateSnippetTemplate(snippet);
    if (!data) return undefined;
  
    snippetLoading[snippet.name] = true;
    const res = await process.command(data);
    snippetLoading[snippet.name] = false;
    return res;
  
  }
  

return {
    snippetLoading,
    snippetMenu,
    runSnippet,
    evaluateSnippetTemplate,
};
}
