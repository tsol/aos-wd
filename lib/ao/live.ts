import { connect } from '@permaweb/aoconnect'

import { usePersistStore } from '~/store/persist';

export async function live(pid: string) {
  const store = usePersistStore();

  let cursor = store.getAllCursors[pid] || undefined;

  let results = await connect().results({
    process: pid,
    sort: cursor ? "ASC" : "DESC",
    from: cursor,
    limit: 1000
  });

  // console.log('results', results);
  
  let result: string[] = [];

  if (! results?.edges?.length) return null;

  const edges = cursor ? results.edges : results.edges.reverse();
  const lastNode = edges[ edges.length - 1 ];
  
  if (lastNode) {
    if (cursor !== lastNode.cursor) {
      cursor = lastNode.cursor
      // console.log('new cursor:', cursor)
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