import { connect } from '@permaweb/aoconnect'
import type { Edge } from './ao.models';

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
    }
  }

  return edges;
}