export function shortenCutMiddle(st: string, maxLength: number) {

  if (!st || st.length < maxLength) return st;

  if (maxLength < 5) return st.slice(0, maxLength);

  const remainsAtEachSide = Math.floor((maxLength - 3) / 2);
  const remainsAtStart = remainsAtEachSide;
  const remainsAtEnd = maxLength - remainsAtStart - 3;

  const first = st.slice(0, remainsAtStart);
  const last = st.slice(-1 * remainsAtEnd);

  return `${first}...${last}`;
}


export function extractTemplateVariables(code: string): string[] {
  const variablePattern = /{{(\w+)}}/g;
  let match;
  const variableNames = new Set<string>();

  while ((match = variablePattern.exec(code)) !== null) {
      variableNames.add(match[1]);
  }

  return Array.from(variableNames);
}