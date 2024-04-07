
export function parseLuaObject(text: string) {

   // Remove ANSI sequences
   text = text.replace(/\x1b\[[0-9;]*m/g, '');

  if (!text.match(/^\s*\{.+\}\s*$/s))
    return undefined;

  let processedString = text
    .replace(/=\s*function: 0x[0-9a-f]+/g, '="function"')
    .replace(/([_-\w]+)\s*=\s*/g, '"$1": ')
    .replace(/([_-\w]+)\s*:/g, '"$1":')
    .replace(':[]', ':{}');

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