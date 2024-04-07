import { parseLuaObject } from "~/lib/parser";

let inputString = `{
  TimeRemaining = 1142870,
  GameMode = "Playing",
  Players = {
    g-CkHRNljAd5FXRebFBhib2LLXtxwfN1C-G4V5Xibjg = {
      x = 20,
      y = 29,
      energy = 20,
      health = 100
   },
    3UZd2tPUDPyCMPdjEECkRDA2gyWMggfCptzzi__a6l0 = {
      x = 15,
      y = 2,
      energy = 20,
      health = 100
   },
    Oeu7OngU4PBt5qczQc6Alh9bHjS1RIgirE3kYwhuQhQ = {
      x = 4,
      y = 14,
      energy = 20,
      health = 100
   },
    o2cH6cZ7d80VCOhPQaqbnLxMySUYmbL3nqF5X8aa3cs = {
      x = 24,
      y = 10,
      energy = 20,
      health = 100
   }
 }
}
`;

inputString = '{"TimeRemaining":21007,"GameMode":"Waiting","Players":[]}';


let parsedObject = parseLuaObject(inputString);

import { z } from "zod";

const GameState = z.object({
  TimeRemaining: z.number(),
  GameMode: z.enum(["Playing", "Waiting"]),
  Players: z.record(z.object({
    x: z.number(),
    y: z.number(),
    energy: z.number(),
    health: z.number()
  }))
});


console.log(GameState.safeParse(parsedObject));