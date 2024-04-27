import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';

type State = {
  botPid: string;
  toBotQuantity: number;
  toGameQuantity: number;
}

import ViewComponent from './utils.vue';

const CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"

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
      name: 'MY CODE',
      data: `
Handlers.add("CronMessage",
  function (msg) if msg.Cron then return 1 end
  return 0
end,
function(msg)
  print("CronMessage")
end
)      
`   },
    {
      name: 'Load CRED',
      data: '.load-blueprint credUtils',
    },
    {
        name: 'Balance',
        data: `Send({ Target = "${CRED}", Action = "Balance", Tags = { Target = ao.id } })`,
    },
    {
        name: 'Pay CRED',
        data: `Send({Target = "${CRED}", Action = "Transfer", Quantity = "{{quantity}}", Recipient = "{{recipentPid}}"})`,
    },
    {
        name: 'Tick self',
        data: `Send({Target = ao.id, Action = "Tick"})`,
    },
    {
        name: 'Last Msg',
        data: 'Inbox[#Inbox]',
    }
  ],
};

export { widget, type State };


