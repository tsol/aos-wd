<template>
  <div>
    <div class="d-flex flex-row justify-space-around">
      <span>Mode: {{ gameMode }}</span>
      <span>Time Left: {{ timeRemainingInSeconds }} </span>
    </div>
    <div class="d-flex flex-row justify-space-between">
      <div ref="canvas" @click="onCanvasClick"></div>
      <div>
        <v-btn @click="setTarget" :active="selectingTarget">
          <v-icon>mdi-target</v-icon>
        </v-btn>
        <div>
        BS = {{ state?.gameState?.BotState }}
      </div>
      </div>
    </div>
  </div>
</template>

<script lang="ts" setup>
import { ref, computed, watch } from 'vue';
import { type State } from '../botgame';
import { Renderer } from './renderer';
import { useProcess } from '~/composables/useProcess';

const props = defineProps<{
  pid: string,
  state?: State
}>();

const process = useProcess(props.pid);

const canvas = ref<HTMLDivElement | null>(null);
const renderer = ref<ReturnType<typeof Renderer> | null>(null);
const redrawCount = ref(0);

const selectingTarget = ref(false);

const gameMode = computed(() => {
  return props.state?.gameState?.GameMode || 'Unknown';
});

const timeRemainingInSeconds = computed(() => {
  return ((props.state?.gameState?.TimeRemaining || 0) / 1000).toFixed(2);
});

function setTarget() {
  selectingTarget.value = ! selectingTarget.value;
}

function onCanvasClick() {
  if (!selectingTarget.value) return;

  const m = renderer.value?.getMouseCell();
  if (!m) return;

  console.log('onCanvasClick', m);
  process.command(`cmdGoTo(${m.x}, ${m.y})`);
  selectingTarget.value = false;
}

watch([() => props.state, () => canvas.value], () => {
  console.log('botgame state changed');
  if (!canvas.value) return;

  if (renderer.value) {
    redrawCount.value++;
    if (props.state)
      renderer.value.redraw(props.state);
    return;
  }

  if (!props.state) return;

  renderer.value = Renderer();
  renderer.value.init(canvas.value, props.pid);

}, { immediate: true, deep: true });



</script>