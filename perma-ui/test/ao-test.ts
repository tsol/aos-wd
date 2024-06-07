import { connect } from '@permaweb/aoconnect'
// import type { Edge } from './ao.models';

export async function getWelcomeScreen(pid: string) {

  let results = await connect().results({
    process: pid,
    sort: "DESC",
    from:  undefined,
    limit: 1
  });

  console.log('results:', JSON.stringify(results, null, 2));
}

async function main() {
  await getWelcomeScreen('6qxtA3JeLEqUYRrt8WjFGn2AOVySg9UpjzPORyws3pg');
}

main();