import type { State } from "./ui-state-parser";
import { initVue } from "./vue-init";
import { computed, watch, nextTick } from "vue";
import { useWallet } from '../../core/useWallet';

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

  const pageStateRef = computed(() => {
    const currentPagePath = state.value?.ui?.path;
    if (!currentPagePath) return { 'no': currentPagePath };
    return state.value.pagesState?.[currentPagePath] || { 'no1': currentPagePath };
  });


  function getRootPage() {

    console.log('useUI-getRootPage');

    state.value.noonceSent = undefined;
    state.value.noonceRecieved = undefined;
    state.value.html = '';

    const tags = [
      { name: "Action", value: "UIGetPage" },
      { name: "Path", value: "/" },
    ];

    aoSendMsg(tags);
  };


  function renderHtml() {
 
    console.log('useUI-renderHtml, appId:', !!appId.value, 'sent:', state.value.noonceSent, 'recieved:', state.value.noonceRecieved, 'loading:', loading.value);

    if (!appId.value) return;

    const currentHtml = appId.value?.innerHTML;
    const html = state.value?.html || currentHtml || "Waiting for html...";
      
    if (vueApp) vueApp.unmount();

    nextTick(() => {
      vueApp = initVue({
        html,
        stateRef: state,
        pageStateRef,
        loadingRef: loading,
        aoSendMsg,
        wallet: useWallet(),
      });
      vueApp.mount(appId.value!);
      // console.log('**** mounted vueApp: ', vueApp, 'on appId:', appId.value!);
    });


  }

  watch([() => state.value?.html, appId], () => {

    console.log('useUI-watch-state/html', state.value?.html, appId.value);
    renderHtml();

  }, { immediate: true, deep: true });


  return {
    aoSendMsg,
    loading,
    getRootPage,
    renderHtml,
  };
}