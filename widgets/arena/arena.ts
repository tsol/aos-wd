import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';
import arena from '~/blueprints/arena.lua';

type State = {
  balance: string;
}

import ViewComponent from './arena.vue';

const widget: WidgetDefinition<State> = {
  name: 'Arena',
  component: ViewComponent,
  types: {
    balance: z.string()
  },
  parsers: [
  ],
  
  snippets: [
    {
        name: 'Load AO-Effect Arena',
        data:  arena,
    },
    {
        name: 'Load Token',
        data: '.load-blueprint token',
    },
    {
        name: 'Players',
        data: 'Players',
    },
    {
        name: 'Waiting',
        data: 'Waiting',
    },
    {
        name: 'Force Start',
        data: 'Send({Target = ao.id, Action = "ForceNow"})',
    },
  ],
};

export { widget, type State };


