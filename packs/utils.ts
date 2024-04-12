


import { z } from 'zod';
import type { PackDefinition } from '~/models/pack';

type State = {
  balance: string;
}

import ViewComponent from './utils.vue';

const CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
const BOT = "GwZJb9O1h1hJ8ralYcrJ6iZH75nHoPUH47BnIimbESc";

const GAME = "wudLa8_VIjHZ6VA5ZG1ZHZs5CYkaIUw4Je_ePYEqmGQ";
const QUANTITY_BOT = "10";
const QUANTITY_GAME = "10"

const MY_CRED="exlB2Q38aOsUELeEINVSH_cK5P1BXhLe7S77lgUFG7Y";
const QUANTITY_MY_CRED = 1000 * 1000;

/*
CRED_PROCESS = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
Send({ Target = CRED_PROCESS, Action = "Balance", Tags = { Target = ao.id } })

    {
      name: 'ARENA',
      data:
`
BOT = ao.id
Game = "wudLa8_VIjHZ6VA5ZG1ZHZs5CYkaIUw4Je_ePYEqmGQ"
CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
Send({Target = CRED, Action = "Transfer", Quantity = "10", Recipient = BOT})
Send({Target = CRED, Action = "Transfer", Quantity = "10", Recipient = Game})
Send({Target = ao.id, Action = "Tick"})
`
    },

*/

const pack: PackDefinition<State> = {
  name: 'Utils',
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
        name: 'Get Balance',
        data: `Send({ Target = "${CRED}", Action = "Balance", Tags = { Target = ao.id } })`,
    },
    {
        name: 'Transfer to MY_CRED',
        data: `Send({Target = "${CRED}", Action = "Transfer", Quantity = "${QUANTITY_MY_CRED}", Recipient = "${MY_CRED}"})`,
    },
    {
        name: 'Send to BOT',
        data: `Send({Target = "${GAME}", Action = "Transfer", Quantity = "${QUANTITY_BOT}", Recipient = "${BOT}"})`,
    },
    {
        name: 'Send to GAME',
        data: `Send({Target = "${GAME}", Action = "Transfer", Quantity = "${QUANTITY_GAME}", Recipient = "${GAME}"})`,
    },
    {
        name: 'Tick',
        data: `Send({Target = ao.id, Action = "Tick"})`,
    },
  ],
};

export { pack, type State };


