<template>
  <span>
    {{ prettyTimeLeft }}
  </span>
</template>

<script lang="ts" setup>
import { computed, onMounted, onUnmounted, ref } from 'vue';
import { runCommand } from './shared/runCommand';
import type { InitVueParams } from '../lib/vue-init';

const props = defineProps<{
  timestampEnd: number;
  reachedText?: string;

  uiRun?: string;
  uiArgs?: Record<string, any>;
  aoSendMsg?: InitVueParams['aoSendMsg'],

}>();

const currentCount = ref(new Date().getTime());

watch ([ () => props.timestampEnd ], () => {
  currentCount.value = new Date().getTime();
});

const timeLeft = computed(() => {
  return props.timestampEnd - currentCount.value;
});

const prettyTimeLeft = computed(() => {
 
  if (timeLeft.value <= 0) {
    return props.reachedText || '...';
  }

  const time = timeLeft.value;
  const seconds = Math.floor((time / 1000) % 60);
  const minutes = Math.floor((time / 1000 / 60) % 60);
  const hours = Math.floor((time / (1000 * 60 * 60)) % 24);
  const days = Math.floor(time / (1000 * 60 * 60 * 24));
  if (days > 0) {
    return `${days}d ${hours}h ${minutes}m ${seconds}s`;
  } else if (hours > 0) {
    return `${hours}h ${minutes}m ${seconds}s`;
  } else if (minutes > 0) {
    return `${minutes}m ${seconds}s`;
  } else {
    return `${seconds}s`;
  }
});

let interval: NodeJS.Timeout;

onMounted(() => {
  interval = setInterval(() => {
    // do not update the value if it is already past the end
    if (currentCount.value > props.timestampEnd + 3000) {

      if (props.uiRun && props.aoSendMsg) {
        const params = {
          uiRun: props.uiRun,
          uiArgs: props.uiArgs,
          aoSendMsg: props.aoSendMsg,
        };
        runCommand(params);
      }

      clearInterval(interval);
      return;
    }
    currentCount.value += 1000;
  }, 1000);

});

onUnmounted(() => {
    clearInterval(interval);
});

</script>

