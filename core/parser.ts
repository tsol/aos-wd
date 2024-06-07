import type { BaseWidgetDefinition } from "./core.models";

import { type Edge } from "./ao/ao.models";
import { textFromMsg } from "./ao/helpers";

export function parseMessagesToState(
  widgets: BaseWidgetDefinition<any>[],
  state: Ref<any>,
  textOutput?: string,
  msg?: Edge,
  myPid?: string,
) {

  let data = textOutput;
  if (!data) {
    if (msg) {
      data = textFromMsg(msg);
    }
  }

  const msgs = msg?.node.Messages;

  // console.log('parsing_msgs:', msgs, 'data:', data);

  widgets.forEach((wd) => {
    // console.log(' - wd.name:', wd.name);

    const parsersByTag = wd.parsers.filter((p) => p.fromTag);

    msgs?.forEach((msg) => {
      parsersByTag.forEach((parser) => {

        if (parser.targetMe) {
          if (msg.Target !== myPid) return;
        }

        if (!Object.entries(parser.matchTags || {}).every(([key, value]) => {
          const tag = msg.Tags?.find((t) => t.name === key);
          return tag && tag.value === value;
        })) return;


        const tag = parser.fromTag === 'Data' ? { value: msg.Data } :
          msg.Tags?.find((t) => t.name === parser.fromTag);

        if (tag) {
          runThroughParser(tag.value, wd, [parser], state);
        }
      }
      );

      if (data) {
        const parsersByText = wd.parsers.filter((p) => !p.fromTag);
        if (parsersByText.length === 0) return;
        runThroughParser(data, wd, parsersByText, state);
      }

    });

  });
}

export function parseObjects(text?: string) {

  if (!text) return undefined;

  let breaks = text.replace(/}\s*{/g, '}|bReAk|{');
  breaks = breaks.replace(/}\s*</g, '}|bReAk|<');
  breaks = breaks.replace(/>\s*{/g, '>|bReAk|{');

  const parts = breaks.split('|bReAk|').map((part) => part.replace(/^[^{]+/, '').replace(/[^}]+$/, ''));

  return parts.map((part) => parseLuaObject(part));

}

function isLuaObject(text: string) {
  return text.match(/[\w-]+\s*=\s*"?[\w\d_-]+"?/s);
}

function luaToJson(text: string) {
  return text
    .replace(/=\s*function: 0x[0-9a-f]+/g, '="function"')
    .replace(/:\[\]/g, ':{}')

    .replace(/^\s*\{\s*\{(.+)\s*\}\s*\}\s*$/s, '[ { $1 } ]');
}

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

  let processedString = text.trim();

  if (isLuaObject(text)) {
    processedString = luaToJson(text);
  }

  //     .replace(/([-_\w\d]+)\s*=\s*/g, '"$1": ')

  // if variable name is not quoted, quote it
  processedString = processedString
    .replace(/([{,]\s*)([-_\w\d]+)\s*[:=]/g, '$1"$2":')


  console.log('*** JSON?:', processedString);

  let parsed: any = undefined;

  try {
    parsed = JSON.parse(processedString);
  }
  catch (e: any) {
    console.log(e.message);
  }

  console.log('parsed:', parsed);

  return parsed;
}


function runThroughParser(
  text: string,
  wd: BaseWidgetDefinition<any>,
  parsers: BaseWidgetDefinition<any>['parsers'],
  state: Ref<any>
) {

  let data = text;

  console.log('Run-Through-Parser:', text);

  parsers.filter((p) => p.mode === 'handler').forEach((parser) => {
    if (parser.mode !== 'handler') return;

    const handler = parser.handler;
    const result = handler(state.value[wd.name], data);

    if (result) {
      // console.log('prev_state:',state.value[wd.name]);
      // console.log('parse_handler.state:', result.state);
      // console.log('wd.name:', wd.name);

      state.value[wd.name] = { ... state.value[wd.name],  ... result.state };
      data = result.reducedData;
    }
    return;
  }
  );

  parsers.filter((p) => p.mode === 'store').forEach((parser) => {

    if (parser.mode !== 'store') return;

    const objects = parseObjects(data);
    if (!objects || objects.length === 0) return;

    objects.forEach((object) => {

      const variable = parser.variable as any;
      const zodType = (wd.types as any)[variable];
      if (!zodType) throw new Error(`No type found for ${variable}`);

      const parsed = zodType.safeParse(object);

      if (parsed.success) {
        // console.log('parse_store:', parsed.data);
        // console.log('SUCCESS match:', wd.name, 'variable:', variable);
        state.value[wd.name][variable] = parsed.data;
      }


    });


  });
}

