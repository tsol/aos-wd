import type { State } from "./ui-state-parser";
import { initVue } from "./vue-init";
import { computed, watch, nextTick } from "vue";

export type AoSendMsgFunc = (tags: Tag[]) => void;

let vueApp: ReturnType<typeof initVue> | undefined;

export function useUI(
  appId: Ref<HTMLDivElement | undefined>,
  state: Ref<State>,
  sendMesssage: AoSendMsgFunc
) {

  function aoSendMsg(tags: Tag[]) {
    if (!state.value) throw new Error("State is not initialized");
    const noonce = Math.random().toString();
    tags.push({ name: "Noonce", value: noonce });
    state.value.noonceSent = noonce;
    sendMesssage(tags);
  }

  const loading = computed(() => {
    if (!state.value) return true;
    if (!state.value.html) return true;

    if (state.value.noonceSent && state.value.noonceRecieved !== state.value.noonceSent) {
      return true;
    }

    return false;
  });


  function init() {

    console.log('useUI-init');

    state.value.noonceSent = undefined;
    state.value.noonceRecieved = undefined;
    state.value.html = '';

    const tags = [
      { name: "Action", value: "UIGetPage" },
      { name: "Path", value: "/" },
    ];

    aoSendMsg(tags);
  };


  watch([() => state.value?.html, appId], () => {

    // console.log('useUI-watch state.html=', state.value?.html, ' appId = ', appId.value);

    if (state.value?.html === undefined || !appId.value)
      return;

    if (vueApp) vueApp.unmount();

    // <v-app theme="dark">
    // <v-main>
    const html = `
      ${state.value.html || "Waiting for html..."}
      `;
    // </v-main>
    // </v-app>

    nextTick(() => {
      vueApp = initVue({
        html,
        stateRef: state,
        loadingRef: loading,
        aoSendMsg,
      });
      vueApp.mount(appId.value!);
      // console.log('**** mounted vueApp: ', vueApp, 'on appId:', appId.value!);
    });

  }, { immediate: true, deep: true });

  return {
    aoSendMsg,
    loading,
    init,
  };
}