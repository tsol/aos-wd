const BACKEND_URL = "https://arweave-search.goldsky.com/graphql"

async function getWelcomeScreen(txid: string) {

  return fetch(BACKEND_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      query: welcomeScreenQuery(txid)
    })
  }).then(res => res.json())
    .then(data => {
      console.log(JSON.stringify(data, null, 2));
    })
}

function welcomeScreenQuery(txid: string) {
  return `query {
    transactions(first: 1, sort: HEIGHT_DESC, ids: ["${txid}"], tags: [
      { name: "Type", values: ["Process"] },
      { name: "Variant", values: ["ao.TN.1"] },
      { name: "Data-Protocol", values: ["ao"] }
    ]) {
      edges {
        node {
          id
        }
      }
    }
  }`
}
/*
function generateProcessesQuery(address: string) {
  return `query {
    transactions(first: 100, owners: ["${address}"], tags: [
      {name: "Type", values: ["Process"]},
      {name: "Variant", values: ["ao.TN.1"]},
      {name: "Data-Protocol", values: ["ao"]}
    ]) {
      edges {
        node {
          id
          tags {
            name
            value
          }
        }
      }
    }
  }`
}

*/

async function main() {
  await getWelcomeScreen('6qxtA3JeLEqUYRrt8WjFGn2AOVySg9UpjzPORyws3pg');
}

main();