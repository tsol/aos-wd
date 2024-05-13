import { type Edge } from '../../core/ao/ao.models';

import { live } from '../../core/ao/live';
import { evaluate } from '../../core/ao/evaluate';

import { ref } from 'vue';

const cursor = ref<string | undefined>(undefined);

if (localStorage.getItem('cursor')) {
  cursor.value = localStorage.getItem('cursor') as string;
}

let intervalTimer: any = null;

export function useAO(pid: string, ourPid: string, handler: (msg: Edge) => void) {


  function startLive() {
    if (intervalTimer) return;
    intervalTimer = setInterval(async () => {
      const result = await live(pid, cursor);
      if (cursor.value) {
        localStorage.setItem('cursor', cursor.value);
      }

      if (result) {
        result.forEach((msg) => {
          handler(msg);
        })
      }
    }, 3000);
  }

  function stopLive() {
    if (intervalTimer) {
      clearInterval(intervalTimer);
      intervalTimer = null;
    }
  }

  return {
    evaluate,
    startLive,
    stopLive,
  };

}