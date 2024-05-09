import type { State } from "./ui-state";
import { initVue } from "./vue-init";
import { ref, computed, watch } from "vue";

export type AoSendMsgFunc = (tags: Tag[]) => void;
let vueApp: ReturnType<typeof initVue> | undefined;

export function useUI(
  appId: Ref<HTMLDivElement | undefined>,
  state: Ref<State | undefined>,
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
  
  const wasInitialized = ref(false);
  
  watch(() => state.value, () => {
    if (state.value && !wasInitialized.value) {
      wasInitialized.value = true;
      state.value.ui = { '__type': 'UI_STATE' };
      state.value.html = '';
      state.value.noonceRecieved = undefined;
      state.value.noonceSent = undefined;
    }
  });
  
  
  function init() {
    const tags = [
      { name: "Action", value: "UIGetPage" },
      { name: "Path", value: "/" },
    ];
    aoSendMsg(tags);  
  };


  watch([() => state.value?.html, appId], () => {
  
    console.log('useUI-watch', state.value?.html, appId.value);

    if (!state.value?.html || !appId.value)
      return;
    
    if (vueApp) vueApp.unmount();
    vueApp = initVue({
      html: state.value?.html || "No HTML found",
      stateRef: state,
      loadingRef: loading,
      aoSendMsg,
    });

    vueApp.mount(appId.value);
  
  }, { immediate: true, deep: true });
  
  return {
    aoSendMsg,
    loading,
    init,
  };
}