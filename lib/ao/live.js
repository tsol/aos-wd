import { connect } from '@permaweb/aoconnect'

import { usePersistStore } from '~/store/persist';

export async function live(pid) {
  const store = usePersistStore();

  let cursor = store.getAllCursors[pid] || '';

  let results = await connect().results({
    process: pid,
    sort: "DESC",
    cursor,
    limit: 1
  });
  const xnode = results.edges.filter(
    x => x.node.Output.print === true
  )[0]
  if (xnode) {

    if (cursor !== xnode.cursor) {
      cursor = xnode.cursor
      console.log('new cursor:', cursor)
      store.updateCursor(pid, cursor);  
    }

    const data = xnode.node.Output.data;
    //console.log('cursor:', cursor, 'data:', data);
    return data;
  }
  return null
}