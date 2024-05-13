import { connect, createDataItemSigner } from '@permaweb/aoconnect'

const prompt = usePrompt();

/*
{
    "Messages": [
        {
            "Tags": [
                {
                    "value": "ao",
                    "name": "Data-Protocol"
                },
                {
                    "value": "ao.TN.1",
                    "name": "Variant"
                },
                {
                    "value": "Message",
                    "name": "Type"
                },
                {
                    "value": "6qxtA3JeLEqUYRrt8WjFGn2AOVySg9UpjzPORyws3pg",
                    "name": "From-Process"
                },
                {
                    "value": "SBNb1qPQ1TDwpD_mboxm2YllmMLXpWw4U8P9Ff8W9vk",
                    "name": "From-Module"
                },
                {
                    "value": "262",
                    "name": "Ref_"
                },
                {
                    "value": "UI_RESPONSE",
                    "name": "Action"
                }
            ],
            "Data": "<html><!--noonce:0.8944082465104151-->        <h1>UI Example</h1>\n        <p>Enter your name:</p>\n        <ui-input ui-id=\"name\" ui-type=\"String\" ui-required label=\"Your name\" />\n        <ui-input\n          ui-id=\"fruit\"\n          ui-type=\"Select\"\n          ui-required\n          label=\"Your fruit\"\n          :items=\"['Apple', 'Banana', 'Cherry', 'Mango']\"\n        />\n        <ui-button ui-valid=\"name, fruit\" ui-run=\"cmdLogin({ name = $name, fruit = $fruit })\">Login</ui-button>\n      </html>",
            "Anchor": "00000000000000000000000000000262",
            "Target": "KjpdUofQA4FSBgMV7CsdcqV4CNZMz-AZayNHcirjEnY"
        }
    ],
    "Assignments": [],
    "Spawns": [],
    "Output": [],
    "GasUsed": 674644018
}
*/

export async function evaluate(pid, data, tags = [{ name: 'Action', value: 'Eval' }]) {

  console.log('evaluate_sending:', data, tags)
  
  const messageId = await connect().message({
    process: pid,
    signer: createDataItemSigner(globalThis.arweaveWallet),
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

  if (result.Output?.data?.prompt) {
    prompt.value = result.Output?.data?.prompt;
  }
  
  const output = result.Output?.data?.output;
  if (output) {
    // console.log('evaluate_output:', output)
    return output
  }
  
  // console.log('evaluate: no output')
  return undefined

}