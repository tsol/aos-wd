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
  handlers: [
  ],
  snippets: [
    {
        name: 'Load Game',
        data:  arena,
    },
  ],
};

export { widget, type State };


