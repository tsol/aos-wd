export async function findPid(name, address) {

  return fetch("https://arweave-search.goldsky.com/graphql", {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      query: generateQuery(name, address)
    })
  }).then(res => res.json())
    .then(data => {
      return data.data?.transactions?.edges[0]?.node?.id
    })
}

function generateQuery(name, address) {
  return `query {
    transactions(owners: ["${address}"], tags: [
      {name: "Name", values: ["${name}"]},
      {name: "Type", values: ["Process"]},
      {name: "Variant", values: ["ao.TN.1"]},
      {name: "Data-Protocol", values: ["ao"]}
    ]) {
      edges {
        node {
          id
        }
      }
    }
  }`
}