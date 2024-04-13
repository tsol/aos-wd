<template>
  <div>
    <div class="d-flex flex-row justify-space-between">
      <span>Mode: {{ gameMode }}</span>
      <span>Time Left: {{ timeRemainingInSeconds }} </span>
    </div>

    <div ref="canvas"></div>

  </div>
</template>

<script lang="ts" setup>
import { ref, onMounted, watch } from 'vue';
import p5 from 'p5';
import { type State } from './botgame';
import { shortenCutMiddle } from '@/lib/utils';

const props = defineProps<{
  pid: string,
  state?: State
}>();

const canvas = ref<HTMLDivElement | null>(null);
const redrawCount = ref(0);

const gameMode = computed(() => {
  return props.state?.gameState?.GameMode || 'Unknown';
});

const timeRemainingInSeconds = computed(() => {
  return ((props.state?.gameState?.TimeRemaining || 0) / 1000).toFixed(2);
});

const sketch = (p: p5) => {

  p.setup = () => {
    p.createCanvas(400, 400);
  };

  p.draw = () => {

    p.background(220);

    p.strokeWeight(0);
    p.stroke('black');
    p.fill('black');


    const state = props.state?.gameState;
    if (!state) {
      p.text(`No game state yet`, 10, 20);
      return;
    }


    p.text(`${redrawCount.value}, ${timeRemainingInSeconds.value}`, 10, 20);

    if (state.Players)
      Object.entries(state.Players).forEach(([key, player], index) => {

        p.strokeWeight(1);
        
        if (key === props.pid) {
          p.stroke('blue'); // Set border color to blue
        } else {
          p.stroke('black'); // Set border color to black
        }

        p.fill('white');

        p.rect(player.x * 10, player.y * 10, 10, 10);

        if (p.mouseX > player.x * 10 && p.mouseX < player.x * 10 + 10 && p.mouseY > player.y * 10 && p.mouseY < player.y * 10 + 10) {
          // Display a popup with the player's data
          p.fill(255);
          p.rect(p.mouseX, p.mouseY, 120, 50);
          p.fill(0);
          p.strokeWeight(0);
          p.stroke('black');
          p.text(`Player ${shortenCutMiddle(key, 9)}`, p.mouseX + 10, p.mouseY + 20);
          p.text(`Health: ${player.health}`, p.mouseX + 10, p.mouseY + 30);
          p.text(`Energy: ${player.energy}`, p.mouseX + 10, p.mouseY + 40);
        }

      });
  };

};


let p5Instance: p5 | null = null;

watch([() => props.state, () => canvas.value], () => {
  console.log('botgame state changed');
  if (canvas.value) {
    if (!p5Instance) {
      p5Instance = new p5(sketch, canvas.value);
    } else {
      redrawCount.value++;
      p5Instance.redraw();
    }
  }
}, { immediate: true, deep: true });

</script>