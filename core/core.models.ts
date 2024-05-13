
import { z } from 'zod';

type ZodTypes<T> = {
  [P in keyof T]: z.ZodType<T[P]>;
};

export type ParseHandler<STATE> = {
  history: boolean;
  matchTags?: Record<string, string>; // if not defined will parse printed data
  fromTag?: string;
  targetMe?: boolean;
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

export type BaseWidgetDefinition<STATE> = {
  name: string;
  types: ZodTypes<STATE>;
  parsers: ParseHandler<STATE>[];
}
