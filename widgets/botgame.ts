
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
      "M8dBmtGdsa83UQ8npuqdBl0XJwmk6hmPq9JiuPA1kK4":{
         "energy":100,
         "name":"SpongeBob",
         "x":23,
         "lastTurn":1713893788226,
         "health":100,
         "y":25
      },
      "DvAidxRhPhFg2Ds1jQPfupztC09F6vkumetxstvfIR8":{
         "energy":4,
         "x":7,
         "lastTurn":1713898915722,
         "health":92,
         "y":29
      },
      "M_AiUdJeKFhnOz8HeiUQXcr8NNX-2oHYhSeReuWe_14":{
         "energy":0,
         "name":"MrsPuff",
         "x":20,
         "lastTurn":1713899451076,
         "health":100,
         "y":36
      },
      "6-m4zbMA9VLLpXo6xqq2UCydNPtFiSnHHDfWBbPOQHo":{
         "energy":3,
         "name":"Sandy",
         "x":23,
         "lastTurn":1713899464781,
         "health":100,
         "y":33
      },
      "UiqtBPN1-VHYAhMWOCP7mOQ1CRPJS9kt3yHDX05Wodg":{
         "energy":3,
         "name":"Morpheus ",
         "x":9,
         "lastTurn":1713898877068,
         "health":100,
         "y":29
      },
      "3UsfBLroKA0O1o4AfK6FAVtHHrQ6uiDbUNLL5DAt3bE":{
         "energy":7,
         "x":27,
         "lastTurn":1713899467469,
         "health":97,
         "y":18
      },
      "WyOhdgYSyFg5oMfLsUEQNcK_Uq52216ChuWnGEu2l3g":{
         "energy":7,
         "name":"Mouse",
         "x":8,
         "lastTurn":1713898892130,
         "health":49,
         "y":28
      },
      "0jF1b2TUFlsYEjv_4CAhMjD-fTMgvXpUT8GST197GyE":{
         "energy":4,
         "x":9,
         "lastTurn":1713899095325,
         "health":88,
         "y":27
      },
      "qem8pui6tENw28p3q6aa9sumIx6hXP-f5O6iUMUdlMo":{
         "energy":7,
         "x":27,
         "lastTurn":1713899466198,
         "health":97,
         "y":17
      },
      "4NFvD-hvpyOr4IzRlDYyBaqNQLJR7srtOJbUAkH8Gzc":{
         "energy":7,
         "name":"Squidward",
         "x":14,
         "lastTurn":1713899453181,
         "health":82,
         "y":28
      },
      "P1fLhMGeHt4aKj3AxsWB_PiSVpphuZYvx0L1cF_-EG8":{
         "energy":4,
         "x":9,
         "lastTurn":1713899440533,
         "health":57,
         "y":27
      },
      "FHch3B_uGXfoin73cUTJ7iHoQhLdwR0BJfkR0VcaI5o":{
         "energy":8,
         "name":"p",
         "x":12,
         "lastTurn":1713899464852,
         "health":87,
         "y":24
      },
      "AAPbz1BerTKQ-_0IidH0Hxnvqx0r-Bv36UMkqss3Pq4":{
         "energy":36,
         "x":20,
         "lastTurn":1713899466421,
         "health":58,
         "y":33
      },
      "dnPhC0KEAFGdwzY_anDxP_-UsfItQG_iulOWoOHl7M8":{
         "energy":36,
         "x":27,
         "lastTurn":1713899467763,
         "health":55,
         "y":17
      },
      "xLZ0l0HbAFaxq5n-sSmKZhcFGPvDe1weSYr1vTF6EnY":{
         "energy":3,
         "name":"Patrick",
         "x":18,
         "lastTurn":1713899461739,
         "health":93,
         "y":1
      },
      "4eEt00QAWiOQ4d1OnCeSO8Xt2bUplAtfhBvyZKILnEE":{
         "energy":36,
         "x":27,
         "lastTurn":1713899467539,
         "health":58,
         "y":17
      },
      "goY3OmfVsCMIpG412wdaZwq5kw_yJgX28ii7JMSE31A":{
         "energy":0,
         "x":27,
         "lastTurn":1713899466673,
         "health":100,
         "y":18
      },
      "HPg3SY_J-bDN5tIoTqlESDUw2ZVfmci4aeRp_lauV_4":{
         "energy":4,
         "x":7,
         "lastTurn":1713898917343,
         "health":92,
         "y":27
      },
      "55HWh_v0Jp6yQ34-2zQZMYXFG4alX_l0Cjcc_Ax8fZU":{
         "energy":3,
         "x":9,
         "lastTurn":1713898909318,
         "health":100,
         "y":29
      },
      "NeThGgE83gyPndyHeNAvj9g2q_UOE0N6Wtiyqy4ZaSk":{
         "energy":36,
         "x":27,
         "lastTurn":1713899467411,
         "health":58,
         "y":17
      },
      "4StyIth9mkUUJ2ME0sqDvYB_RH-HhIaUShzvz4s1bJ4":{
         "energy":7,
         "name":"Regulator",
         "x":16,
         "lastTurn":1713897731348,
         "health":66,
         "y":29
      },
      "Ka1BiZ6KzTzUXt8FZbGchsz_8hs16QwUmRvmbzKSgto":{
         "energy":15,
         "name":"Points Coin",
         "x":12,
         "lastTurn":1713899467854,
         "health":73,
         "y":27
      }
   },
   "BotState":{
      "friends":{
         "0jF1b2TUFlsYEjv_4CAhMjD-fTMgvXpUT8GST197GyE":{
            "index":1
         },
         "55HWh_v0Jp6yQ34-2zQZMYXFG4alX_l0Cjcc_Ax8fZU":{
            "index":2
         },
         "HPg3SY_J-bDN5tIoTqlESDUw2ZVfmci4aeRp_lauV_4":{
            "index":4
         },
         "P1fLhMGeHt4aKj3AxsWB_PiSVpphuZYvx0L1cF_-EG8":{
            "index":5
         },
         "DvAidxRhPhFg2Ds1jQPfupztC09F6vkumetxstvfIR8":{
            "index":3
         }
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
      "PWu5xrOORfcbVPkCXpOlMuvsXuKUoFhChmrBLcS2t5g":"2502000",
      "M8dBmtGdsa83UQ8npuqdBl0XJwmk6hmPq9JiuPA1kK4":"2500000",
      "DvAidxRhPhFg2Ds1jQPfupztC09F6vkumetxstvfIR8":"1000",
      "M_AiUdJeKFhnOz8HeiUQXcr8NNX-2oHYhSeReuWe_14":"1250000",
      "6-m4zbMA9VLLpXo6xqq2UCydNPtFiSnHHDfWBbPOQHo":"625000",
      "UiqtBPN1-VHYAhMWOCP7mOQ1CRPJS9kt3yHDX05Wodg":"1000",
      "6bxc6ekwEnIEsicBpwOm6R6mx5fD_w3AFN5I3xvhERQ":"0",
      "3UsfBLroKA0O1o4AfK6FAVtHHrQ6uiDbUNLL5DAt3bE":"1000",
      "WyOhdgYSyFg5oMfLsUEQNcK_Uq52216ChuWnGEu2l3g":"1000",
      "qem8pui6tENw28p3q6aa9sumIx6hXP-f5O6iUMUdlMo":"1000",
      "4R3n2kNO4LUGmGOizsQgafRsTRqZ0WAoUgkzQGAQ_J4":"0",
      "dnPhC0KEAFGdwzY_anDxP_-UsfItQG_iulOWoOHl7M8":"1000",
      "0jF1b2TUFlsYEjv_4CAhMjD-fTMgvXpUT8GST197GyE":"1000",
      "xLZ0l0HbAFaxq5n-sSmKZhcFGPvDe1weSYr1vTF6EnY":"1250000",
      "4NFvD-hvpyOr4IzRlDYyBaqNQLJR7srtOJbUAkH8Gzc":"2500000",
      "P1fLhMGeHt4aKj3AxsWB_PiSVpphuZYvx0L1cF_-EG8":"6000",
      "FHch3B_uGXfoin73cUTJ7iHoQhLdwR0BJfkR0VcaI5o":"2000",
      "AAPbz1BerTKQ-_0IidH0Hxnvqx0r-Bv36UMkqss3Pq4":"1000",
      "gx-V74zhDLOZpK2EmGzgzK9TwagsyGcLz6jb4XIF5dg":"0",
      "4eEt00QAWiOQ4d1OnCeSO8Xt2bUplAtfhBvyZKILnEE":"1000",
      "4StyIth9mkUUJ2ME0sqDvYB_RH-HhIaUShzvz4s1bJ4":"1000",
      "goY3OmfVsCMIpG412wdaZwq5kw_yJgX28ii7JMSE31A":"1000",
      "Ka1BiZ6KzTzUXt8FZbGchsz_8hs16QwUmRvmbzKSgto":"1000",
      "55HWh_v0Jp6yQ34-2zQZMYXFG4alX_l0Cjcc_Ax8fZU":"1000",
      "NeThGgE83gyPndyHeNAvj9g2q_UOE0N6Wtiyqy4ZaSk":"1000",
      "HPg3SY_J-bDN5tIoTqlESDUw2ZVfmci4aeRp_lauV_4":"1000",
      "HTnOpakx5_5BPJlzGL3PNQvvDN2VyGis4RZni-BRPaU":"9999999991237000"
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


