import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';

type State = {
}

import ViewComponent from './console.vue';

const widget: WidgetDefinition<State> = {
  name: 'Console',
  component: ViewComponent,
  types: {
  },
  parsers: [
  ],
  
  snippets: [
  ],
};

export { widget, type State };


