import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';

type State = {
  botPid: string;
  toBotQuantity: number;
  toGameQuantity: number;
}

import ViewComponent from './utils.vue';

const CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
const ARENA_GAME = "wudLa8_VIjHZ6VA5ZG1ZHZs5CYkaIUw4Je_ePYEqmGQ";

const widget: WidgetDefinition<State> = {
  name: 'Utils',
  component: ViewComponent,
  types: {
    botPid: z.string(),
    toBotQuantity: z.number(),
    toGameQuantity: z.number(),
  },
  parsers: [
  ],
  handlers: [
  ],
  snippets: [
    {
        name: 'Get Balance',
        data: `Send({ Target = "${CRED}", Action = "Balance", Tags = { Target = ao.id } })`,
    },
    {
        name: 'Pay Arena for bot',
        data: `Send({Target = "${CRED}", Action = "Transfer", Quantity = "{{toBotQuantity}}", Recipient = "{{botPid}}"})`,
    },
    {
        name: 'Pay Arena to play',
        data: `Send({Target = "${CRED}", Action = "Transfer", Quantity = "{{toGameQuantity}}", Recipient = "${ARENA_GAME}"})`,
    },
    {
        name: 'Tick self',
        data: `Send({Target = ao.id, Action = "Tick"})`,
    },
  ],
};

export { widget, type State };


