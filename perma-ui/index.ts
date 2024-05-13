
import type { Edge } from "~/lib/ao/live";
import { parseMessagesToState } from "../lib/parser";
import { type State, widget } from "./lib/ui-state-parser";
import { useAO } from "./lib/useAO";
import { useAWW } from "./lib/useAWW";
import { useUI } from "./lib/useUI";
import { ref, watch, computed } from "vue";


const widgetsState = ref<{ 'UI': State }>({ UI: {
  ui: { '__type': 'UI_STATE' },
  html: '',
  noonceRecieved: undefined,
  noonceSent: undefined,
}});

const state = computed({
  get: () => widgetsState.value.UI,
  set: (value) => { widgetsState.value.UI = value; }
});

var PID = ''; getProcessPid().then(pid => PID = pid);

const appId = ref<HTMLDivElement | undefined>();
const aww = useAWW();
let ao: ReturnType<typeof useAO> | undefined = undefined;

async function getProcessPid() {

  let processId: string | null | undefined =
    await fetch(window.location.href, { method: 'HEAD' })
      .then(res => res.headers.get('x-arns-resolved-id'));

  if (!processId) {
    processId = window.location.pathname.split('/')[1]
  }

  if (! processId || processId.length !== 43) {
    console.error('invalid pid:', processId);
    processId = '6qxtA3JeLEqUYRrt8WjFGn2AOVySg9UpjzPORyws3pg';
  }

  return processId;
}


watch( [aww.ourPID, appId], () => {
  
  console.log('init watch', aww.ourPID.value, appId.value);

  if (!aww.ourPID.value || !appId.value) return;

  console.log('*** REINITIALIZING ***');

  if (ao) { ao.stopLive(); }

  ao = useAO(PID, aww.ourPID.value, 
    (msg: Edge) => parseMessagesToState([widget], widgetsState, undefined, msg, aww.ourPID.value)
  );

  const ui = useUI(
    appId,
    state,
    (tags: Tag[]) => {
  
      console.log('Sending message:', tags);

      const dataTagIndex = tags.findIndex(t => t.name === 'Data');
      const data = dataTagIndex !== -1 ? tags[dataTagIndex].value : '';
      const tagsWithoutData = tags.filter((_, i) => i !== dataTagIndex);

      // ao?.evaluate(data, tagsWithoutData);

      ao?.evaluate(data, tagsWithoutData).then((result) => {
        console.log('evaluate result:', result);
        parseMessagesToState([widget], widgetsState, undefined, {
          cursor: '',
          node: result 
        }, aww.ourPID.value)
      });

    }
  );

  ui.init();
  ao.startLive();
  
});

function uiInit(el: HTMLDivElement) {
  appId.value = el;
}

(window as any).uiInit = uiInit;

export default uiInit;
