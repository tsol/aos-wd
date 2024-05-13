import type { WidgetDefinition } from '~/models/widgets';
import * as Base from '../../perma-ui/lib/ui-state-parser';

import uiLibrary from '~/perma-ui/blueprints/ui-library.lua'
import uiExample from '~/perma-ui/blueprints/ui-example.lua'

import ViewComponent from './ui.vue';

type State = Base.State;

const widget: WidgetDefinition<State> = {
  ...Base.widget,
  component: ViewComponent,
  snippets: [
    {
      name: 'My Code',
      data: uiExample,
    },
    {
      name: 'Load LIB',
      data: uiLibrary,
    },
  ],
};

export { widget, type State };


