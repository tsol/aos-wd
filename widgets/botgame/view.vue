<template>
  <div class="container">
    <div class="col-1">
      <div class="d-flex flex-column align-center">
        <div>
        <div class="d-flex flex-row justify-space-between">
          <span>Mode: {{ gameMode }}</span>
          <span>Time Left: {{ timeRemainingInSeconds }} </span>
        </div>
        <div ref="canvas" @click="onCanvasClick"></div>
      </div>
      </div>
    </div>
    <div class="col-2">
      <div class="w-100 d-flex flex-column align-center">

        <PlayerStat :players="players" />

        <div class="mt-4">
          <v-btn @click="setTarget" :active="selectingTarget">
            <v-icon>mdi-target</v-icon>
          </v-btn>
        </div>

      </div>
    </div>
  </div>
</template>

<style scoped>
.container {
  display: flex;
  flex-wrap: wrap;
}

.col-1 {
  flex: 1 0 400px;
}

.col-2 {
  flex: 1 0 150px;
}

@media (max-width: 550px) {
  .container {
    flex-direction: column;
  }
}
</style>

<script lang="ts" setup>
import { ref, computed, watch } from 'vue';
import { type State } from '../botgame';
import { Renderer } from './renderer';
import { useProcess } from '~/composables/useProcess';

import PlayerStat from './player-stat.vue';

const props = defineProps<{
  pid: string,
  state?: State
}>();

const process = useProcess(props.pid);

const canvas = ref<HTMLDivElement | null>(null);
const renderer = ref<ReturnType<typeof Renderer> | null>(null);
const redrawCount = ref(0);

const selectingTarget = ref(false);

const players = computed(() => {
  return Object.entries(props.state?.gameState?.Players || {})
    .map(([pid, player]) => ({
      pid, ...player,
      friendIndex: props.state?.gameState?.BotState?.friends?.[pid]?.index,
      isVictim: props.state?.gameState?.BotState?.victim === pid,
      balance: Number(props.state?.gameState?.PlayerBalances?.[pid] || 0) / 1000,
    }));
});

const gameMode = computed(() => {
  return props.state?.gameState?.GameMode || 'Unknown';
});

const timeRemainingInSeconds = computed(() => {
  return ((props.state?.gameState?.TimeRemaining || 0) / 1000).toFixed(2);
});

function setTarget() {
  selectingTarget.value = !selectingTarget.value;
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