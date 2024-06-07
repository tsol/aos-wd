import { connect, createDataItemSigner } from '@permaweb/aoconnect'

export async function evaluate(pid: string, data: string, tags = [{ name: 'Action', value: 'Eval' }]) {

  if (! window.arweaveWallet.signDataItem) {
    console.error('arweaveWallet.signDataItem not found');
    return;
  }

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

  // console.log('evaluate_result:', result);
  return result;
}
