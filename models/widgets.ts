import type { BaseWidgetDefinition } from "~/core/core.models";

export type Snippet = {
  name: string;
  pid?: string;
  tags?: Array<Tag>;
  data?: string;
}

export type LuaHandler = {
  name: string;
  code: string;
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