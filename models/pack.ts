
import { z } from 'zod';

export type Snippet = {
  name: string;
  code: string;
}

export type ParseHandler<STATE> = {
  history: boolean;
} & ( {
  mode: 'handler';
  handler: (state: STATE, ...args: any[]) => STATE;
} | {
  mode: 'regex';
  regex: RegExp;
  variables: (keyof STATE)[];
} | {
  mode: 'store';
  variable: keyof STATE;
}
);

export type LuaHandler = {
  name: string;
  code: string;
}

type ZodTypes<T> = {
  [P in keyof T]: z.ZodType<T[P]>;
};

export type PackDefinition<STATE> = {

  component: any;

  name: string;
  types: ZodTypes<STATE>;
  parsers: ParseHandler<STATE>[];
  handlers: LuaHandler[];
  snippets: Snippet[];
}

export type Pack<STATE> = {
  definition: PackDefinition<STATE>;
  state: STATE;
  history: STATE[];
}