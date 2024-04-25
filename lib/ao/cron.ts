
import { createDataItemSigner, monitor, unmonitor } from "@permaweb/aoconnect";

declare global {
  interface Window {
    arweaveWallet: any;
  }
}

const arweave = window.arweaveWallet;

export async function startMonitor(pid: string) {
  if (!arweave) throw new Error('Arweave wallet not found');

  const result = await monitor({
    process: pid,
    signer: createDataItemSigner(arweave),
  });
  return result;
}

export async function stopMonitor(pid: string) {

  const result = await unmonitor({
    process: pid,
    signer: createDataItemSigner(arweave),
  });

  return result;

}