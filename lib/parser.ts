


import type { BaseWidgetDefinition } from "~/models/widgets";

// this parses both LUA output of table and JSON
// [] replaced by {}
export function parseLuaObject(text?: string) {

  if (!text)
    return undefined;
  
  // first exctract code starting from the first '{' to the last '}'

  let start = text.indexOf('{');
  let end = text.lastIndexOf('}');
  if (start < 0 || end < 0)
    return undefined;

  text = text.slice(start, end + 1);

  // Remove ANSI sequences
  text = text.replace(/\x1b\[[0-9;]*m/g, '');

  if (!text.match(/^\s*\{.+\}\s*$/s))
    return undefined;

  let processedString = text
    .replace(/=\s*function: 0x[0-9a-f]+/g, '="function"')
    .replace(/([_-\w]+)\s*=\s*/g, '"$1": ')
    .replace(/([_-\w]+)\s*:/g, '"$1":')
    .replace(/:\[\]/g, ':{}');

  processedString = processedString.replace(/^\s*\{\s*\{(.+)\s*\}\s*\}\s*$/s, '[ { $1 } ]');

  let parsed: any = undefined;

  try {
    parsed = JSON.parse(processedString);
  }
  catch (e: any) {
    console.error(e.message);
  }
  
  // console.log('parsed:', parsed);

  return parsed;
}


export function parseProcess(widgets: BaseWidgetDefinition<any>[], state: Ref<any>, srcData: string) {

  let data = srcData;

  console.log('parsing_data:', data);

  widgets.forEach((wd) => {
    console.log(' - wd.name:', wd.name);

    wd.parsers.filter((p) => p.mode === 'handler').forEach((parser) => {
      if (parser.mode !== 'handler') return;

      const handler = parser.handler;
      const result = handler(state.value[wd.name], data);

      if (result) {
        // console.log('prev_state:',state.value[wd.name]);
        // console.log('parse_handler.state:', result.state);
        // console.log('wd.name:', wd.name);

        state.value[wd.name] = result.state;
        data = result.reducedData;
      }
      return;
    }
    );

    wd.parsers.filter((p) => p.mode === 'store').forEach((parser) => {

      if (parser.mode !== 'store') return;

      const object = parseLuaObject(data);
      if (!object) return;

      const variable = parser.variable as any;
      const zodType = (wd.types as any)[variable];
      if (!zodType) throw new Error(`No type found for ${variable}`);

      const parsed = zodType.safeParse(object);
      if (parsed.success) {
        // console.log('parse_store:', parsed.data);
        // console.log('wd.name:', wd.name, 'variable:', variable);
        state.value[wd.name][variable] = parsed.data;
      }

    });
  });

}
