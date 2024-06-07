
import type { Edge } from "../core/ao/ao.models";
import { type State, widget } from "./lib/ui-state-parser";
import { parseMessagesToState } from "../core/parser";

import { useAO } from "./lib/useAO";
import { useWallet } from "../core/useWallet";
import { useUI } from "./lib/useUI";

import { ref, watch, computed } from "vue";

const widgetsState = ref<{ 'UI': State }>({
  UI: {
    ui: { '_type': 'UI_STATE' },
    pagesState: { '_type': 'UI_PAGE_STATE' },
    html: '',
    noonceRecieved: undefined,
    noonceSent: undefined,
  }
});

const state = computed({
  get: () => widgetsState.value.UI,
  set: (value) => { widgetsState.value.UI = value; }
});

var PID = ''; getProcessPid().then(pid => PID = pid);
const appId = ref<HTMLDivElement | undefined>();

const aww = useWallet();
let ao: ReturnType<typeof useAO> | undefined = undefined;
let ui: ReturnType<typeof useUI> | undefined = undefined;


async function getProcessPid() {

  let processId: string | null | undefined =
    await fetch(window.location.href, { method: 'HEAD' })
      .then(res => res.headers.get('x-arns-resolved-id'));

  if (!processId) {
    processId = window.location.pathname.split('/')[1]
  }

  if (!processId || processId.length !== 43) {
    console.error('bad pid from url:', processId);
    processId = '6qxtA3JeLEqUYRrt8WjFGn2AOVySg9UpjzPORyws3pg';
  }

  return processId;
}

function createUI() {

 console.log('createUI');
 return useUI(
    appId,
    state,
    (tags: Tag[]) => {

      const dataTagIndex = tags.findIndex(t => t.name === 'Data');
      const data = dataTagIndex !== -1 ? tags[dataTagIndex].value : '';
      const tagsWithoutData = tags.filter((_, i) => i !== dataTagIndex);

      ao?.evaluate(PID, data, tagsWithoutData).then((result) => {
        result && parseMessagesToState([widget], widgetsState, undefined, {
          cursor: '',
          node: result
        }, aww.ourPID.value)
      });

    }
  );
}

watch([aww.ourPID, appId], () => {

  console.log('index watch ourPid / appId', aww.ourPID.value, appId.value);

  if (!aww.ourPID.value && !appId.value) return;

  if (appId.value) {

    if (!ui) ui = createUI();
    ui.renderHtml();

  }
  
  if (!aww.ourPID.value) {
    aww.init();
    return;
  }

  console.log('*** REINITIALIZING ***');

  if (ao) { ao.stopLive(); }

  ao = useAO(PID, aww.ourPID.value,
    (msg: Edge) => parseMessagesToState([widget], widgetsState, undefined, msg, aww.ourPID.value)
  );

  ao.startLive();

  ui?.getRootPage();

});

function uiInit(el: HTMLDivElement) {
  appId.value = el;
}

(window as any).uiInit = uiInit;

export default uiInit;
