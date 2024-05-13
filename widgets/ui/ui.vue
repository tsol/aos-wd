<template>
  <div ref="appId"></div>
  <div v-if="loading" class="text-center">
    <v-progress-circular indeterminate color="primary"></v-progress-circular>
  </div>
</template>

<script lang="ts" setup>

import type { State } from './ui';
import { useUI } from '~/perma-ui/lib/useUI';

const props = defineProps<{
  pid: string;
  state: State;
}>();

const { ourPID } = useWallet();

const process = useProcess(props.pid);
const appId = ref<HTMLDivElement | undefined>();

const { init, loading } = useUI(
  appId,
  toRef(props, 'state'),
  (tags: Tag[]) => {

    const dataTagIndex = tags.findIndex(t => t.name === 'Data');
    const data = dataTagIndex !== -1 ? tags[dataTagIndex].value : '';
    const withoutData = tags.filter((_, i) => i !== dataTagIndex);

    process.command(data, false, withoutData);
  }
);

watch( ourPID, () => {
  if (ourPID.value) init();
}, { immediate: true });


</script>
