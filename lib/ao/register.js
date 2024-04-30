import { connect, createDataItemSigner } from '@permaweb/aoconnect'

const MODULE = "SBNb1qPQ1TDwpD_mboxm2YllmMLXpWw4U8P9Ff8W9vk"
const SCHEDULER = "_GQ33BkPtZrqxA84vM8Zk-N2aO0toNNu_C-l-rawrBA"

export async function register(name, cronMode) {

  if (!globalThis.arweaveWallet) {
    throw new Error('ArConnect is Required!')
  }

  const tags = [
    { name: 'Name', value: name },
    { name: 'Version', value: 'web-0.0.1' }
  ];

  if (cronMode) {
    tags.push({ name: 'Cron-Interval', value: cronMode });
    tags.push({ name: 'Cron-Tag-Action', value: 'Cron' });
  }

  const aos = connect();
  
  const pid = await aos.spawn({
    module: MODULE,
    scheduler: SCHEDULER,
    signer: createDataItemSigner(globalThis.arweaveWallet),
    tags,
    data: '1984'
  })
  return pid
}
