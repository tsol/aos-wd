
import { z } from 'zod';

export type Snippet = {
  name: string;
  pid?: string;
  tags?: Array<Tag>;
  data?: string;
}

export type ParseHandler<STATE> = {
  history: boolean;
} & ( {
  mode: 'handler';
  handler: (state: STATE, data: string) => { state: STATE, reducedData: string } | undefined;
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

export type BaseWidgetDefinition<STATE> = {
  name: string;
  types: ZodTypes<STATE>;
  parsers: ParseHandler<STATE>[];
}

export type WidgetDefinition<STATE> = BaseWidgetDefinition<STATE> & {
  component: any;
  snippets: Snippet[];
}

export type Widget<STATE> = {
  definition: WidgetDefinition<STATE>;
  state: STATE;
  history: STATE[];
}