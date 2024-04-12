import { connect, createDataItemSigner } from '@permaweb/aoconnect'

const prompt = usePrompt();

export async function evaluate(pid, data) {
  // connect wallet 
  // await globalThis.arweaveWallet.connect([
  //   'SIGN_TRANSACTION'
  // ])
  console.log('evaluate_sending:', data)
  
  const messageId = await connect().message({
    process: pid,
    signer: createDataItemSigner(globalThis.arweaveWallet),
    tags: [{ name: 'Action', value: 'Eval' }],
    data
  })
  const result = await connect().result({
    message: messageId,
    process: pid
  })
  //console.log(result)
  if (result.Error) {
    throw new Error(JSON.stringify(result.Error))
  }

  if (result.Output?.data?.prompt) {
    prompt.value = result.Output?.data?.prompt;
  }
  
  const output = result.Output?.data?.output;
  if (output) {
    console.log('evaluate_output:', output)
    return output
  }
  
  console.log('evaluate: no output')
  return undefined

}