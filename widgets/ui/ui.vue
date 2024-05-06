<template>  
  <div>
    <!-- state is {{ state }} -->
    <VueInsideVue :pid="pid" :html="state?.html || ''" :state="state?.ui" :loading="loading"/>
    <div v-if="loading" class="text-center">
      <v-progress-circular indeterminate color="primary"></v-progress-circular>
    </div>
  </div>
</template>

<script lang="ts" setup>
import VueInsideVue from './vue-inside-vue.vue';

import type { State } from './ui';

const props = defineProps<{
  pid: string,
  state?: State
}>();

const wasInitialized = ref(false);

const loading = computed(() =>{
  if (!props.state) return true;
  if (! props.state.html) return true;
  
  if (props.state.noonceSent && props.state.noonceRecieved !== props.state.noonceSent) {
    return true;
  }
  return false;

});

watch (() => props.state, () => {
  if (props.state && !wasInitialized.value) {
    wasInitialized.value = true;
    props.state.ui = { '__type': 'UI_STATE' };
    props.state.html = '';
    props.state.noonceRecieved = undefined;
    props.state.noonceSent = undefined;
  }
});


</script>