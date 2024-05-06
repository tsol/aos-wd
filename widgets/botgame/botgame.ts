
import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';
import botGameLua from '~/blueprints/botgame.lua';

/*
{
   "GameMode":"Playing",
   "Players":{
      "PWu5xrOORfcbVPkCXpOlMuvsXuKUoFhChmrBLcS2t5g":{
         "energy":4,
         "name":"Gary",
         "x":27,
         "lastTurn":1713899451404,
         "health":89,
         "y":18
      },
   },
   "BotState":{
      "friends":{
         "0jF1b2TUFlsYEjv_4CAhMjD-fTMgvXpUT8GST197GyE":{
            "index":1
         },
      },
      "targetXY":{
         "x":9,
         "y":29
      },
      "mode":"arrived",
      "requestedFriends":true,
      "victim":"WyOhdgYSyFg5oMfLsUEQNcK_Uq52216ChuWnGEu2l3g"
   },
   "PlayerBalances":{
      "rJysLf2VD0HFMd-A_N-THaVVs2mxSilc_pnCc3v-hp8":"0",
   }
}
 */

const GameState = z.object({
  TimeRemaining: z.number().optional().nullable(),
  GameMode: z.enum(["Playing", "Waiting"]),
  Players: z.record(z.object({
    x: z.number(),
    y: z.number(),
    name: z.string().optional().nullable(),
    lastTurn: z.number().optional().nullable(),
    energy: z.number(),
    health: z.number()
  })),
  BotState: z.object({
    mode: z.string(),
    targetXY: z.object({
      x: z.number(),
      y: z.number(),
    }),
    victim: z.string().optional().nullable(),
    friends: z.record(z.object({
      index: z.number(),
    })).optional(),
  }).optional(),
  PlayerBalances: z.record(z.string()).optional(),
});

type State = {
  gameState?: z.infer<typeof GameState>;

  gamePid?: string;
  betQuantity: number;
  attackEnergy: number;
}

export type Player = NonNullable<State['gameState']>['Players'][string];

import ViewComponent from './view.vue';

const widget: WidgetDefinition<State> = {
  name: 'BotGame',
  component: ViewComponent,
  types: {
    gameState: GameState,
    gamePid: z.string(),
    attackEnergy: z.number(),
    betQuantity: z.number(),
  },
  parsers: [
    {
      mode: 'store',
      history: true,
      variable: 'gameState'
    }
  ],
  handlers: [
  ],
  snippets: [
    {
      name: 'Init BOT',
      data: botGameLua,
    },
    {
      name: 'Register',
      data: 'Send({ Target = Game, Action = "Register" })',
    },
    {
      name: 'Request tokens',
      data: 'Send({ Target = Game, Action = "RequestTokens"})',
    },
    {
      name: 'Bet',
      data: `Send({ Target = Game, Action = "Transfer", Recipient = Game, Quantity = "{{betQuantity}}"})`,
    },
    {
      name: 'Attack',
      data: 'Send({ Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = "{{attackEnergy}}"})',
    },
    {
      name: 'Withdraw',
      data: 'Send({ Target = Game, Action = "Withdraw"})',
    },
    {
      name: 'GetState',
      data: 'Send({ Target = Game, Action = "GetGameState" })',
    },
  ]
};

export { widget, type State };


