import { connect, createDataItemSigner, dryrun } from '@permaweb/aoconnect'
import { live, type Edge } from '../../lib/ao/live';
import { ref } from 'vue';

const cursor = ref<string | undefined>(undefined);

// restore cursor from localStorage

if (localStorage.getItem('cursor')) {
  cursor.value = localStorage.getItem('cursor') as string;
}

let intervalTimer: any = null;

export function useAO(pid: string, ourPid: string, handler: (msg: Edge) => void) {

  async function rundry(data = "", tags: Tag[] = []) {

    const evaluatedTags = tags.map((tag) => {
      const newTag = { ...tag };
      if (tag.value === 'ao.id')
        newTag.value = ourPid;
      return tag;
    });

    const result = await dryrun({
      process: pid,
      Owner: ourPid,
      tags: evaluatedTags,
      data,
    });

    if (result.Error) {
      throw new Error(JSON.stringify(result.Error))
    }

    // const forMe = result.Messages
    //   .filter((msg: any) => msg.Target === ownerPid);

    return result;
  }



  async function evaluate(data: string, tags = [{ name: 'Action', value: 'Eval' }]) {

    const messageId = await connect().message({
      process: pid,
      signer: createDataItemSigner(window.arweaveWallet),
      tags,
      data
    })

    const result = await connect().result({
      message: messageId,
      process: pid
    })

    if (result.Error) {
      throw new Error(JSON.stringify(result.Error))
    }

    console.log('evaluate_result:', result);
    return result;
  }


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
    rundry,
  };


}