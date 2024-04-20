
import { z } from 'zod';
import type { WidgetDefinition } from '~/models/widgets';
import botGameLua from '~/blueprints/botgame.lua';

/*

{
   "GameMode":"Playing",
   "Players":{
      "OwobNCCgQaiOb1W37rY6VMpWeZHDIpmGw7mj71-4WvA":{
         "energy":100,
         "name":"Points Coin",
         "x":14,
         "lastTurn":1713654916480,
         "health":85,
         "y":33
      },
      "PWu5xrOORfcbVPkCXpOlMuvsXuKUoFhChmrBLcS2t5g":{
         "energy":14,
         "name":"Gary",
         "x":12,
         "lastTurn":1713654913615,
         "health":35,
         "y":25
      },
      "M8dBmtGdsa83UQ8npuqdBl0XJwmk6hmPq9JiuPA1kK4":{
         "energy":100,
         "name":"SpongeBob",
         "x":19,
         "lastTurn":1713639997985,
         "health":100,
         "y":34
      },
      "MvHWzSw4orLAAZ9wj1KNFpTyLBv440PSY5uCzCY05IA":{
         "energy":84,
         "name":"asfw",
         "x":36,
         "lastTurn":1713654906310,
         "health":100,
         "y":31
      },
      "soplia3":{
         "energy":3,
         "x":38,
         "lastTurn":0,
         "health":100,
         "y":35
      },
      "OhFP35hrwZnbSXurhqavgayXEN7Oy8Ufj6rKriWh6pM":{
         "energy":56,
         "name":"asfw",
         "x":37,
         "lastTurn":1713654382195,
         "health":100,
         "y":13
      },
      "VPOpf0g9g-Opang_RqZeEpxOhbdvnkWrSpDUy0P3W7o":{
         "energy":84,
         "name":"asfw",
         "x":35,
         "lastTurn":1713654903245,
         "health":100,
         "y":17
      },
      "eEgrNybozTD-E48-VpNoMZiPKcu6NqQ58JIw8aC5xM0":{
         "energy":42,
         "name":"ocgboi435",
         "x":27,
         "lastTurn":1713654907716,
         "health":100,
         "y":25
      },
      "M_AiUdJeKFhnOz8HeiUQXcr8NNX-2oHYhSeReuWe_14":{
         "energy":59,
         "name":"MrsPuff",
         "x":4,
         "lastTurn":1713654913744,
         "health":87,
         "y":37
      },
      "4StyIth9mkUUJ2ME0sqDvYB_RH-HhIaUShzvz4s1bJ4":{
         "energy":100,
         "name":"Regulator",
         "x":16,
         "lastTurn":1713653479990,
         "health":99,
         "y":16
      },
      "vCe-KpGf8fZHiGBOgSq7aPbnawCkufSR4Hi0Swo4aRk":{
         "energy":100,
         "name":"x",
         "x":37,
         "lastTurn":1713652456108,
         "health":100,
         "y":14
      },
      "6b_DVnlqcnnPntvlyTPZmBZjeEi24YSR0_pep4GTC3k":{
         "energy":84,
         "name":"asfw",
         "x":37,
         "lastTurn":1713654911026,
         "health":100,
         "y":12
      },
      "UIZclJRgflffAlNMbfFCw2IJPRMlVjgMSO5NQJAVI9I":{
         "energy":6,
         "x":22,
         "lastTurn":0,
         "health":100,
         "y":39
      },
      "0jF1b2TUFlsYEjv_4CAhMjD-fTMgvXpUT8GST197GyE":{
         "energy":5,
         "x":17,
         "lastTurn":0,
         "health":100,
         "y":32
      },
      "Tt7KL4mloyt3XYxF0dsTrv0b4ssMljnRPANZWA6MsHk":{
         "energy":100,
         "name":"asfw",
         "x":36,
         "lastTurn":1713635820413,
         "health":73,
         "y":32
      },
      "-uJGDIgmrhWE0F2JM59OjVRGv5E0Z9zTbMD2PNfyFhg":{
         "energy":100,
         "name":"asfw",
         "x":31,
         "lastTurn":1713645709195,
         "health":62,
         "y":22
      },
      "wPpB0njQ2jMufb9g75JwlwaBO_WWx-uUF8ihdzt6u50":{
         "energy":3,
         "x":23,
         "lastTurn":0,
         "health":100,
         "y":35
      },
      "GEZxuNyIpC2E8i_4x5BW1v-T7j5G8vWUOQ4PCLDlJfU":{
         "energy":100,
         "name":"asfw",
         "x":30,
         "lastTurn":1713645637884,
         "health":100,
         "y":11
      },
      "4NFvD-hvpyOr4IzRlDYyBaqNQLJR7srtOJbUAkH8Gzc":{
         "energy":84,
         "name":"Squidward",
         "x":31,
         "lastTurn":1713654924363,
         "health":100,
         "y":15
      },
      "LO2P7KzaoiTKZ-ewYKIjT7MNRqwS7USQgdPDf2Zh7fE":{
         "energy":100,
         "name":"Beta",
         "x":26,
         "lastTurn":1713653219928,
         "health":76,
         "y":15
      },
      "GIggaGe8AwATmW8iAGUoXaPNN1lx18dC9GLc1cCsV48":{
         "energy":100,
         "x":27,
         "lastTurn":0,
         "health":39,
         "y":14
      },
      "jgGOF4APPCO7YRfZQMoSenbTfKvT53KknKbCPsn3qJM":{
         "energy":100,
         "name":"l",
         "x":32,
         "lastTurn":1713635788549,
         "health":46,
         "y":29
      },
      "xXPyrcloFuZaMDlYCz-Mb2sRlODwGJgc1bTtV1BVQpM":{
         "energy":84,
         "name":"asfw",
         "x":22,
         "lastTurn":1713654897878,
         "health":100,
         "y":37
      },
      "8YfXRIXEXDMYTCNpnLINP-WjlofYtY_kpq4hyWWOPhQ":{
         "energy":84,
         "name":"asfw",
         "x":13,
         "lastTurn":1713654879686,
         "health":100,
         "y":10
      },
      "3UsfBLroKA0O1o4AfK6FAVtHHrQ6uiDbUNLL5DAt3bE":{
         "energy":100,
         "x":7,
         "lastTurn":1713643193916,
         "health":73,
         "y":32
      },
      "HBReZHOwaXwzmQE54wD7FuSAAIGoubXAt-bcha99M6o":{
         "energy":3,
         "x":33,
         "lastTurn":0,
         "health":100,
         "y":37
      },
      "czovN0wXOaA7pY-I_E9c6KoJT7TQ7ugvKif0YLVI7dY":{
         "energy":88,
         "name":"asfw",
         "x":8,
         "lastTurn":1713654916765,
         "health":100,
         "y":32
      },
      "55HWh_v0Jp6yQ34-2zQZMYXFG4alX_l0Cjcc_Ax8fZU":{
         "energy":9,
         "x":36,
         "lastTurn":0,
         "health":100,
         "y":2
      },
      "u39N5UttvlKmMVaLOweZ6rET0vzZSQ4xad0fH1ve8WY":{
         "energy":78,
         "name":"txohyeah",
         "x":14,
         "lastTurn":1713654920140,
         "health":100,
         "y":15
      },
      "xeho_X9LTzKvzAyegBdOYOnpbWO-O4Dq0yt3At2DkqA":{
         "energy":87,
         "name":"asfw",
         "x":37,
         "lastTurn":1713654896509,
         "health":100,
         "y":34
      },
      "YNEW5P3xykzG5prMsSPg6jYHBlRkqieeMCak9-OmDus":{
         "energy":87,
         "name":"asfw",
         "x":40,
         "lastTurn":1713654890851,
         "health":100,
         "y":1
      }
   },
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


