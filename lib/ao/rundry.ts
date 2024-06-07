import { dryrun } from "@permaweb/aoconnect";

export async function rundry(process: string, owner: string, data = "", tags: Tag[] = []) {

  const evaluatedTags = tags.map((tag) => {
    const newTag = { ...tag };
    if (tag.value === 'ao.id')
      newTag.value = process;
    return tag;
  });

  const result = await dryrun({
    process,
    Owner: owner,
    tags: evaluatedTags,
    data,
  });

  if (result.Error) {
    throw new Error(JSON.stringify(result.Error))
  }

  return result;
}
