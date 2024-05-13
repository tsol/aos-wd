<template>
  <div ref="appId"></div>
</template>

<script lang="ts" setup>

import { useWallet } from '~/core/useWallet';
import type { State } from './ui';
import { useUI } from '~/perma-ui/lib/useUI';

const props = defineProps<{
  pid: string;
  state: State;
}>();

const { ourPID } = useWallet();

const process = useProcess(props.pid);
const appId = ref<HTMLDivElement | undefined>();

const { init } = useUI(
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
