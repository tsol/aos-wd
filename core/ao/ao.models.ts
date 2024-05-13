export type Edge = {
  cursor: string,
  node: {
    Output: {
      data: {
        prompt: string,
        json: any,
        output?: string,
      }
    } | Array<any> | {
      print: boolean,
      data: string,
    },
    Messages: {
      Tags: {
        value: string,
        name: string
      }[],
      Data: string,
      Anchor: string,
      Target: string
    }[],
    Spawns: any[]
  }
}
