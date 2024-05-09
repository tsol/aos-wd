import { connect, createDataItemSigner } from '@permaweb/aoconnect'

let cursor: string | undefined = undefined;
let intervalTimer: any = null;

export function useAO(pid: string, handler: (msg: string) => void ){

  async function evaluate(data: string, tags = [{ name: 'Action', value: 'Eval' }]) {

    console.log('evaluate_sending:', data, tags)
    
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
    
    const output = result.Output?.data?.output as string;
    return output || undefined;
  }
  

  async function liveUpdate(pid: string) {

    let results = await connect().results({
      process: pid,
      sort: cursor ? "ASC" : "DESC",
      from: cursor,
      limit: 1000
    });
  
    // console.log('results', results);
    
    let result: string[] = [];
  
    if (! results?.edges?.length) return null;
  
    const edges = cursor ? results.edges.reverse() : results.edges;
    const lastNode = edges[ edges.length - 1 ];
    
    if (lastNode) {
      if (cursor !== lastNode.cursor) {
        cursor = lastNode.cursor
      }
    }
  
    edges.filter(
      (x: any) => x.node.Output.print === true
    ).forEach((xnode: any) => {
      const data = xnode.node.Output.data;
      result.push(data);  
    })
    

    return result.length > 0 ? result : null;
  }
  

  function startLive() {
    if (intervalTimer) return;
    intervalTimer = setInterval(async () => {
      const result = await liveUpdate(pid);
      if (result) {
        console.log('liveUpdate:', result);
        result.forEach((msg: string) => {
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
    stopLive
  };
  

}