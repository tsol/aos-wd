import { connect } from '@permaweb/aoconnect'

import { usePersistStore } from '~/store/persist';

export async function live(pid: string) {
  const store = usePersistStore();

  let cursor = store.getAllCursors[pid] || '';

  let results = await connect().results({
    process: pid,
    sort: "DESC",
    from: cursor,
    limit: 10
  });

  // console.log('results', results);
  
  let result: string[] = [];

  const edges = (results.edges as Array<any>).reverse();

  const lastNode = edges[ edges.length - 1 ];
  
  if (lastNode) {
    if (cursor !== lastNode.cursor) {
      cursor = lastNode.cursor
      console.log('new cursor:', cursor)
      store.updateCursor(pid, cursor);  
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