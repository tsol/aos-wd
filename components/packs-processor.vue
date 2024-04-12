<template>
  <div>
    <div v-for="pack in packs" :key="pack.name" class="mb-4">
      <div class="d-flex align-center">
        <div class="text-caption name">{{ pack.name }}</div>
        <v-divider></v-divider>
      </div>
      <!-- history navigate -->
      <Component :is="pack.component" :pid="pid" :state="states[pack.name]" />
      <v-btn v-for="snippet in pack.snippets" :key="snippet.name" @click="runSnippet(snippet)"
        :loading="snippetLoading[snippet.name]">
        {{ snippet.name }}
      </v-btn>
    </div>
  </div>
</template>

<style scoped>
.name {
  font-weight: bold;
  border: 1px solid;
  padding: 0px 5px;
  border-radius: 5px;
}
</style>

<script lang="ts" setup>

import { pack as BotPack, type State as BotState } from '~/packs/botgame';
import { pack as UtilPack, type State as UtilState } from '~/packs/utils';
import { pack as ArenaPack, type State as ArenaState } from '~/packs/arena';

import { type BrodcastMsg } from '~/composables/useProcesses';
import { parseLuaObject } from '~/lib/parser';
import type { Snippet } from '~/models/pack';

const props = defineProps<{
  pid: string;
}>();

const packs = [BotPack, UtilPack, ArenaPack];
const snippetLoading = reactive<Record<string, boolean>>({});

const states = reactive({
  [BotPack.name]: {} as any,
  [UtilPack.name]: {} as any,
  [ArenaPack.name]: {} as any,
});

const proc = useProcess(props.pid);
proc.addListener({ type: 'parser', handler: listen });

function listen(text: BrodcastMsg[]) {
  // TODO: if brodcast recieved from Dryrun,
  // then try to json parse the data

  if (!text.length) return;

  text.forEach((msg) => {
    process(msg.data);
  });

}

onUnmounted(() => {
  proc.removeListener(listen);
});

async function runSnippet(snippet: Snippet) {

  if (snippet.pid && snippet.tags) {
    snippetLoading[snippet.name] = true;
    console.log('running dry run: ', snippet);
    const res = await proc.rundry(snippet.pid, snippet.tags, snippet.data);
    snippetLoading[snippet.name] = false;
    console.log('dry run res:', res);
    return res;
  }

  if (!snippet.data) return undefined;

  snippetLoading[snippet.name] = true;
  console.log('running data: ', snippet);
  const res = await proc.command(snippet.data);
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
~/composables/useProcesses