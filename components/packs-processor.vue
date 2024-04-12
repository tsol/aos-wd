<template>
  <div>
    <div v-for="pack in packs" :key="pack.name">
      <p class="text-caption">{{ pack.name }}</p>
      <v-divider></v-divider>
      <!-- history navigate -->
      <Component :is="pack.component" :state="states[pack.name]" />
      <v-btn v-for="snippet in pack.snippets" :key="snippet.name" @click="runSnippet(snippet)"
        :loading="snippetLoading[snippet.name]">
        {{ snippet.name }}
      </v-btn>
    </div>
  </div>
</template>

<script lang="ts" setup>

import { pack as BotPack, type State as BotState } from '~/packs/botgame';
import { pack as UtilPack, type State as UtilState } from '~/packs/utils';
import { pack as ArenaPack, type State as ArenaState } from '~/packs/arena';

import { useAO, type BrodcastMsg } from '~/composables/useAO';
import { parseLuaObject } from '~/lib/parser';
import type { Snippet } from '~/models/pack';

const packs = [BotPack, UtilPack, ArenaPack];
const snippetLoading = reactive<Record<string, boolean>>({});

const states = reactive({
  [BotPack.name]: {} as any,
  [UtilPack.name]: {} as any,
  [ArenaPack.name]: {} as any,
});

const ao = useAO();
ao.addListener(listen);

function listen(text: BrodcastMsg[]) {
  // TODO: if brodcast recieved from Dryrun,
  // then try to json parse the data

  if (!text.length) return;

  text.forEach((msg) => {
    process(msg.data);
  });

}

onUnmounted(() => {
  ao.removeListener(listen);
});

async function runSnippet(snippet: Snippet) {

  if (snippet.pid && snippet.tags) {
    snippetLoading[snippet.name] = true;
    console.log('running dry run: ', snippet);
    const res = await ao.run(snippet.pid, snippet.tags, snippet.data);
    snippetLoading[snippet.name] = false;
    console.log('dry run res:', res);
    return res;
  }

  if (!snippet.data) return undefined;

  snippetLoading[snippet.name] = true;
  console.log('running data: ', snippet);
  const res = await ao.command(snippet.data);
  snippetLoading[snippet.name] = false;
  console.log('command res:', res);
  return res;

}

function process(output: string) {
  packs.forEach((pack) => {

    pack.parsers.forEach((parser) => {

      if (parser.mode === 'store') {
        const object = parseLuaObject(output);
        if (!object) return;
        const zodType = (pack.types as any)[parser.variable as any];
        if (!zodType) throw new Error(`No type found for ${parser.variable}`);
        const parsed = zodType.safeParse(object);
        if (parsed.success) {
          states[pack.name as any][parser.variable as any] = parsed.data;
        }
      }

    });

  });

}

</script>
