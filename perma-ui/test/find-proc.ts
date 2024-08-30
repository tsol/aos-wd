import { connect } from '@permaweb/aoconnect'
import type { Edge } from '~/core/ao/ao.models';

const BACKEND_URL = "https://arweave-search.goldsky.com/graphql"

export async function findPid(name: string) {

  return fetch(BACKEND_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      query: generateQuery(name)
    })
  }).then(res => res.json())
    .then(data => {
      return data.data?.transactions?.edges;
    })
}

function generateQuery(name: string) {
  return `query {
    transactions(tags: [
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


export async function processesList(address: string): Promise<{ pid: string, name: string }[]> {
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




/*
 
e: [
  {
    "cursor": "eyJzZWFyY2hfYWZ0ZXIiOlsxNDQxMTYyLCI2S3J1ZDFEZW9rd0xaejJobmJYdnZQOGt6NzdBQ1E0MWhkWkdsRWVCNnJJIl0sImluZGV4IjowfQ==",
    "node": {
      "recipient": "Oeu7OngU4PBt5qczQc6Alh9bHjS1RIgirE3kYwhuQhQ",
      "owner": {
        "address": "KjpdUofQA4FSBgMV7CsdcqV4CNZMz-AZayNHcirjEnY"
      },
      "id": "6Krud1DeokwLZz2hnbXvvP8kz77ACQ41hdZGlEeB6rI",
      "block": {
        "timestamp": 1717882097,
        "height": 1441162
      },
      "tags": [
        {
          "name": "Action",
          "value": "Eval"
        },
        {
          "name": "Data-Protocol",
          "value": "ao"
        },
        {
          "name": "Variant",
          "value": "ao.TN.1"
        },
        {
          "name": "Type",
          "value": "Message"
        },
        {
          "name": "SDK",
          "value": "aoconnect"
        }
      ]
    }
  }
]
*/

type GqlResponseEdge = {
  cursor: string,
  node: {
    recipient: string,
    owner: {
      address: string
    },
    id: string,
    block: {
      timestamp: number,
      height: number
    },
    tags: {
      name: string,
      value: string
    }[]
  }
}

async function runQuery(query: string) {
  return fetch(BACKEND_URL, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      query
    })
  }).then(res => res.json())
    .then(data => {
      return data.data?.transactions?.edges as GqlResponseEdge[];
    })
}


export async function getEvals(to?: string, from?: string, limit: number = 1) {
  const evalResponseEdges = await runQuery(generateEvalsQuery(to, from, limit));
  return evalResponseEdges;
}
//     {name: "SDK", values: ["aoconnect"]},
function generateEvalsQuery(to?: string, from?: string, limit: number = 1) {
  return `query {
    transactions(
      first: ${limit},
      ${to ? `recipients: ["${to}"]` : ''},
      ${from ? `owners: ["${from}"]` : ''}
    tags: [
      {name: "Type", values: ["Message"]},
      {name: "Action", values: ["Eval"]},
      {name: "Data-Protocol", values: ["ao"]},
      {name: "Variant", values: ["ao.TN.1"]}
    ]) {
      edges {
        cursor
        node {
          recipient
          owner { address }
          id
          block { timestamp, height }
          tags {
            name
            value
          }
        }
      }
    }
  }`
}

/*
transactions(
ids: [ID!]
owners: [String!]
recipients: [String!]
tags: [TagFilter!]
bundledIn: [ID!]
ingested_at: RangeFilter
block: RangeFilter
first: Int = 10
after: String
sort: SortOrder = HEIGHT_DESC
): TransactionConnection!
*/

type Unpromise<T extends Promise<any>> = T extends Promise<infer U> ? U : never;


async function compute(messageId: string, pid: string) {
  const result = await connect().result({
    message: messageId,
    process: pid
  })
  // console.log('result:', result);
  return result;
}

type Result = {
  messageId: string,
  timestamp: number,
  to?: string,
  computeResult?: Unpromise<ReturnType<typeof compute>>,
  data?: string,
  gqlResponse?: GqlResponseEdge
}

async function getEvalResults(to?: string, from?: string, limit?: number) {

  const e = await getEvals(to, from, limit);

  const chainResults: Result[] = [];
  const promisesToWait: ReturnType<typeof compute>[] = [];

  e.forEach(async edge => {
    const messageId = edge.node.id;
    const pid = edge.node.recipient;
    const timestamp = edge.node.block.timestamp;

    const computeResult = compute(messageId, pid).then(result => {
      chainResults.push({
        messageId,
        timestamp,
        computeResult: result,
        data: result?.Output.data.output,
        gqlResponse: edge
      });
      return result;
    });

    promisesToWait.push(computeResult);

  })

  await Promise.all(promisesToWait);

  return chainResults;

}

async function main() {

  const p = 'Oeu7OngU4PBt5qczQc6Alh9bHjS1RIgirE3kYwhuQhQ';
  const u = 'KjpdUofQA4FSBgMV7CsdcqV4CNZMz-AZayNHcirjEnY';

  const evalResults = await getEvalResults(u, p, 5);
  
  evalResults.sort((a, b) => a.timestamp - b.timestamp);

  for (const result of evalResults) {
    //console.log(result.data);
    //console.log(JSON.stringify(result.computeResult, null, 2));
    console.log(JSON.stringify(result.gqlResponse, null, 2));
  }
}

main();


// ukkobWjvi0Gwt7SSt2pdQRS2vXsRO3s-kGDx7jQlJdY