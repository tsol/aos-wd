import { z } from 'zod';
import type { BaseWidgetDefinition } from '../../core/core.models';

type State = {
  ui: { '_type': 'UI_STATE' } & Record<string, any>;
  pagesState: { '_type': 'UI_PAGE_STATE' } & Record<string, any>;
  html?: string;
  noonceSent?: string;
  noonceRecieved?: string;
}


const widget: BaseWidgetDefinition<State> = {
  name: 'UI',
  types: {
    ui: z.object({
      '_type': z.literal('UI_STATE'),
    }).passthrough(),
    pagesState: z.object({
      '_type': z.literal('UI_PAGE_STATE'),
    }).passthrough(),
    html: z.string().optional(),
    noonceSent: z.string().optional(),
    noonceRecieved: z.string().optional(),
  },
  parsers: [
    {
      mode: 'store',
      history: false,
      variable: 'ui',
      matchTags: { 'Action': 'UI_RESPONSE' },
      fromTag: 'Data',
      targetMe: true,
    },
    {
      mode: 'store',
      history: false,
      variable: 'pagesState',
      matchTags: { 'Action': 'UI_RESPONSE' },
      fromTag: 'Data',
      targetMe: true,
    },
    {
      mode: 'handler',
      handler: parseNoonceResponse,
      history: false,
      matchTags: { 'Action': 'UI_RESPONSE' },
      fromTag: 'Data',
      targetMe: true,
    },
  ],
};

function parseNoonceResponse(state: State, data?: string) {

  if (! data) {
    console.error('No data to parse');
    return undefined;
  }
  
  const match = data.match(/<!--noonce:(.+?)-->/);

  if (! match) return undefined;

  const noonce = match[1];

  if (state.noonceSent === noonce && state.noonceRecieved !== noonce) {

    state.noonceRecieved = noonce;

    return parseHtmlResponse(state, data);
  }

  console.log('Noonce skip: sent=', state.noonceSent, 'prev_recv=', state.noonceRecieved, 'new=', noonce);
  
  return { state, reducedData: data.replace(/<!--noonce:.+?-->/, '') };
}

function parseHtmlResponse(state: State, data?: string) {

  if (! data) {
    console.error('No data to parse');
    return undefined;
  }

  const match = data.match(/<html>([\s\S]*?)<\/html>/s);
  if (! match) return undefined;

  const htmlCode = match[1].trim();
  if (! htmlCode) return undefined;
  
  const reducedData = data.replace(/<html>[\s\S]*?<\/html>/s, '');
  state.html = htmlCode;
  return { state, reducedData };
};

export { widget, type State };


