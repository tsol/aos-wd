import { z } from 'zod';
import type { BaseWidgetDefinition } from '~/models/widgets';

type State = {
  ui: { '__type': 'UI_STATE' } & Record<string, any>;
  html?: string;
  noonceSent?: string;
  noonceRecieved?: string;
}

const widget: BaseWidgetDefinition<State> = {
  name: 'UI',
  types: {
    ui: z.object({
      '__type': z.literal('UI_STATE'),
    }),
    html: z.string().optional(),
    noonceSent: z.string().optional(),
    noonceRecieved: z.string().optional(),
  },
  parsers: [
    {
      mode: 'store',
      history: false,
      variable: 'ui'
    },
    {
      mode: 'handler',
      handler: parseNoonceResponse,
      history: false,
    },
    {
      mode: 'handler',
      handler: parseHtmlResponse,
      history: false,
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
  state.noonceRecieved = noonce;
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


