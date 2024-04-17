
import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';
import botGameLua from '~/blueprints/botgame.lua';

const GameState = z.object({
  TimeRemaining: z.number(),
  GameMode: z.enum(["Playing", "Waiting"]),
  Players: z.record(z.object({
    x: z.number(),
    y: z.number(),
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
});

type State = {
  gameState?: z.infer<typeof GameState>;

  gamePid?: string;
  betQuantity: number;
  attackEnergy: number;
}

import ViewComponent from './botgame/view.vue';

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
/*    {
      name: 'Move Up',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "Up"})',
    },
    {
      name: 'Move Down',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "Down"})',
    },
    {
      name: 'Move Left',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "Left"})',
    },
    {
      name: 'Move Right',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "Right"})',
    },
    {
      name: 'Move UpRight',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "UpRight"})',
    },
    {
      name: 'Move UpLeft',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "UpLeft"})',
    },
    {
      name: 'Move DownRight',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "DownRight"})',
    },
    {
      name: 'Move DownLeft',
      data: 'Send({ Target = Game, Action = "PlayerMove", Player = ao.id, Direction = "DownLeft"})',
    },
*/
    {
      name: 'Attack',
      data: 'Send({ Target = Game, Action = "PlayerAttack", Player = ao.id, AttackEnergy = "{{attackEnergy}}"})',
    },
    {
      name: 'GetState',
      data: 'Send({ Target = Game, Action = "GetGameState" })',
    },
  ]
};

export { widget, type State };


