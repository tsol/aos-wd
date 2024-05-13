import { connect } from '@permaweb/aoconnect'

export type Edge = {
  cursor: string,
  node: {
    Output: {
      data: {
        prompt: string,
        json: any,
        output?: string,
      }
    } | Array<any> | {
      print: boolean,
      data: string,
    },
    Messages: {
      Tags: {
        value: string,
        name: string
      }[],
      Data: string,
      Anchor: string,
      Target: string
    }[],
    Spawns: any[]
  }
}


export function textFromMsg(msg: Edge) {
  const O = msg.node.Output;
  return Array.isArray(O) ? '' : typeof O.data === 'string' ? O.data : O.data.output;
}

export function getPrintableMessage(msg: Edge) {
  
  const O = msg.node.Output;
  if (Array.isArray(O)) return undefined;

  if (typeof O === 'object' && 'print' in O && O.print === true)
    return O.data;
  
  return undefined;
}

export async function live(pid: string, cursor: Ref<string | undefined>) {

  let results = await connect().results({
    process: pid,
    sort: cursor.value ? "ASC" : "DESC",
    from: cursor.value,
    limit: 1
  });

  if (!results?.edges?.length) return null;

  const edges = (cursor ? results.edges.reverse() : results.edges) as Edge[];
  const lastNode = edges[edges.length - 1];

  if (lastNode) {
    if (cursor.value !== lastNode.cursor) {
      cursor.value = lastNode.cursor;
      // console.log('!! new cursor:', cursor.value);
    }
  }

  // edges.filter(
  //   (x) => x.node.Output.print === true
  // ).forEach((xnode: any) => {
  //   const data = xnode.node.Output.data;
  //   result.push(data);  
  // })

  return edges;
}