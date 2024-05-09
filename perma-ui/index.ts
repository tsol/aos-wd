
import { parseProcess } from "../lib/parser";
import { type State, widget } from "./lib/ui-state";
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

var PID = getProcessPid();

const appId = ref<HTMLDivElement | undefined>();
const aww = useAWW();
let ao: ReturnType<typeof useAO> | undefined = undefined;

function getProcessPid() {
  //return window.location.pathname.split('/').pop() || '';
  return '6qxtA3JeLEqUYRrt8WjFGn2AOVySg9UpjzPORyws3pg';
}

watch( [aww.ourPID, appId], () => {
  
  console.log('init watch', aww.ourPID.value, appId.value);

  if (!aww.ourPID.value || !appId.value) return;

  console.log('*** REINITIALIZING ***');

  if (ao) { ao.stopLive(); }

  ao = useAO(PID, (msg: string) => parseProcess([widget], widgetsState, msg) );

  const ui = useUI(
    appId,
    state,
    (tags: Tag[]) => {
  
      console.log('Sending message:', tags);

      const dataTagIndex = tags.findIndex(t => t.name === 'Data');
      const data = dataTagIndex !== -1 ? tags[dataTagIndex].value : '';
      const tagsWithoutData = tags.filter((_, i) => i !== dataTagIndex);

      ao?.evaluate(data, tagsWithoutData);
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
