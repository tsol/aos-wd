<template>
  <div style="max-height: 300px; overflow-y: auto;">

    <table>
      <tr>
        <th>Name</th>
        <th>
          <!-- emoji heart: -->
          <span>&#x2764;</span>
        </th>
        <th>
          <!-- emoji battery: -->
          <span>&#x1F50B;</span>
        </th>
        <th>
          <!-- balance (dollar) -->
          <span>&#x1F4B5;</span>
        </th>
        <th>
          <span>&#x1F46F;</span>
        </th>
      </tr>
      <tr v-for="player in sortedPlayers" :key="player.pid"
        :style="{ backgroundColor: color(player) }"
      >
        <td class="px-1">{{ player.name || shortenCutMiddle(player.pid, 9) }}</td>
        <td class="px-1">{{ player.health }}</td>
        <td class="px-1">{{ player.energy }}</td>
        <td class="px-1">{{ player.balance }}</td>
        <td class="px-1">{{ player.friendIndex }}</td>
      </tr>
    </table>
  </div>
</template>

<script setup lang="ts">
import type { Player } from '../botgame';
import { shortenCutMiddle } from '../../lib/utils';

type PlayerWithPid = Player & {
  pid: string;
  friendIndex?: number;
  positionIndex?: number;
  isVictim?: boolean;
  balance: number;
};

const props = defineProps<{
  players: PlayerWithPid[],
}>();


function color(player: PlayerWithPid) {
  if (player.isVictim) return `rgb(255, 0, 0, 0.3)`;
  if (player.friendIndex !== undefined) {
    return `rgb(0, 0, 255, 0.3)`;
  }
  return undefined;
}

// sort players by distance from victim (if any)

const sortedPlayers = computed(() => {
  const victim = props.players.find(p => p.isVictim);
  if (!victim) return props.players;

  return props.players.slice().sort((a, b) => {
    const distA = Math.abs(a.x - victim.x) + Math.abs(a.y - victim.y);
    const distB = Math.abs(b.x - victim.x) + Math.abs(b.y - victim.y);
    return distA - distB;
  });
});


</script>
./botgame