<template>
  <div>
    <div v-for="pack in packs" :key="pack.name">
      <p class="text-caption">{{ pack.name }}</p>
      <v-divider></v-divider>
      <!-- history navigate -->
      <Component :is="pack.component" :state="states[pack.name]" />
      <v-btn
        v-for="snippet in pack.snippets"
        :key="snippet.name"
        @click="ao.command(snippet.code)"
      >
        {{ snippet.name }}
      </v-btn>
    </div>
  </div>
</template>

<script lang="ts" setup>

import { pack, type State } from '~/packs/botgame';
import { useAO } from '~/composables/useAO';
import { parseLuaObject } from '~/lib/parser';

const packs = [pack];

const states = reactive({
  [pack.name]: {} as State,
});

const ao = useAO();
ao.addListener(listen);

function listen(text: string[]) {
  if (!text.length) return;

    const output = text.join('\n');

    console.log('pp: output:', output);
    process(output);

}

onUnmounted(() => {
  ao.removeListener(listen);
});

function process(output: string) {
  packs.forEach((pack) => {

    pack.parsers.forEach((parser) => {

      if (parser.mode === 'store') {
        const object = parseLuaObject(output);
        if (!object) return;
        const zodType = pack.types[parser.variable];
        if (!zodType) throw new Error(`No type found for ${parser.variable}`);
        const parsed = zodType.safeParse(object);
        if (parsed.success) {
          states[pack.name][parser.variable] = parsed.data;
        }
      }

    });

  });

}

</script>
