import type { Edge } from "./ao.models";

export function textFromMsg(msg: Edge) {
  const O = msg.node.Output;
  return Array.isArray(O) ? '' : typeof O.data === 'string' ? O.data : O.data.output;
}

export function getPrintableMessage(msg: Edge) {
  
  const O = msg.node.Output;
  if (Array.isArray(O)) return undefined;

  if (typeof O === 'object' && 'print' in O && O.print === true)
    return O.data;
  
  return undefined;
}
