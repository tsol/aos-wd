const BACKEND_URL = "https://arweave-search.goldsky.com/graphql"

export async function findPid(name: string, address: string) {

  return fetch(BACKEND_URL, {
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

function generateQuery(name: string, address: string) {
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

export async function processesList(address: string): Promise<{ pid: string, name: string }[]>{
  return fetch(BACKEND_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      query: generateProcessesQuery(address)
    })
  }).then(res => res.json())
    .then(data => {
      const edges = data.data?.transactions?.edges;
      return edges?.map((edge: any) => {
        return {
          pid: edge.node.id,
          name: edge.node.tags.find((tag: any) => tag.name === 'Name')?.value
        }
      });
    })

}

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

