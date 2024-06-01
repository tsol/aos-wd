import type { State } from "../../lib/ui-state-parser";
import type { InitVueParams } from "../../lib/vue-init";
import { parseLuaObject } from "../../../core/parser";

type RunCommandParams = {
  aoSendMsg: InitVueParams['aoSendMsg'];
  uiRun: string;
  uiArgs?: Record<string, any>;
  state?: State['ui'];
}

export function runCommand(props: RunCommandParams) {

  function parseRunCommand() {

    const match = props.uiRun.match(/([^(]+)\((\{.+\})?\)/);

    if (!match) {
      const args = props.uiArgs || {};
      const jsonedArgs = JSON.stringify(args);
      return { command: props.uiRun, jsonedArgs };
    }

    const command = match[1].trim();
    const args = match[2]?.replace(/[']+/g, '"');

    const cmdArgs = args ? args.replace(/\$([a-zA-Z_][a-zA-Z0-9_]*)/g, (_, name) => {
      return JSON.stringify(props.state?.[name]);
    }) : '';

    const parsedArgs = parseLuaObject(cmdArgs) || {};
    const jsonedArgs = JSON.stringify(parsedArgs);

    return { command, jsonedArgs };

  }

  const { command, jsonedArgs } = parseRunCommand() || {};

  if (!command) return;

  console.log('Running command:', command, 'Args:', jsonedArgs);

  const tags: Tag[] = [
    { name: 'Action', value: 'UIRun' },
    { name: 'Data', value: command },
    { name: 'Args', value: jsonedArgs || '' },
  ];

  props.aoSendMsg(tags);

}

