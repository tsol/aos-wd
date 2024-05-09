import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';

type State = {
  balance: string;
}

import ViewComponent from './ide.vue';

const widget: WidgetDefinition<State> = {
  name: 'Ide',
  component: ViewComponent,
  types: {
    balance: z.string()
  },
  parsers: [
  ],
  snippets: [
  ],
};

export { widget, type State };


