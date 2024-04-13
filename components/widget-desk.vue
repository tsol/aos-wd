<template>
  <div :class="maxColumns > 1 ? undefined : 'v-container'">

    <div class="d-flex align-center mb-4">
      <add-widget :pid="pid" v-slot="{ props }">
        <div v-bind="props" class="text-caption bubble text-no-wrap text-success">Add Widget</div>
      </add-widget>
      <v-divider class="ml-2 mr-2"></v-divider>
      <div class="text-caption bubble bubble-gray text-no-wrap">{{ processName }}</div>
      <v-divider class="ml-2 mr-2"></v-divider>
      <v-icon size="small" color="green" class="bubble my-float-left">mdi-plus</v-icon>
    </div>

    <v-row>

      <!-- <v-col v-for="column in maxColumns" :key="column" :class="`v-col-md-${12 / maxColumns}`"> -->
      <v-col v-for="(column, index) in maxColumns" :key="column"
        :class="`v-col-md-${12 / maxColumns} ${index < maxColumns - 1 ? 'border-right' : ''}`">
        <div v-for="widget in proc.widgets.value.filter((w) => (w.column || 1) === column)" :key="widget.name"
          class="mb-6">

          <div class="d-flex align-center mb-4 text-grey">
            <div class="text-caption bubble">{{ widget.name }}</div>
            <v-divider class="ml-2 mr-2"></v-divider>
            <v-icon size="small" class="bubble mr-1" @click="moveLeft(widget)">mdi-arrow-left</v-icon>
            <v-icon size="small" class="bubble mr-1" @click="moveDown(widget)">mdi-arrow-down</v-icon>
            <v-icon size="small" class="bubble mr-1" @click="moveUp(widget)">mdi-arrow-up</v-icon>
            <v-icon size="small" class="bubble mr-1" @click="moveRight(widget)">mdi-arrow-right</v-icon>
            <v-icon size="small" color="red" class="bubble" @click="proc.removeWidget(widget.name)">mdi-close</v-icon>
          </div>

          <Component :is="getWidgetDefinition(widget.name)?.component" :pid="pid"
            :state="(proc.state.value as any)?.[widget.name]" />

          <!-- <v-btn v-for="snippet in getWidgetDefinition(widget.name)?.snippets || []" :key="snippet.name"
            @click="runSnippet(snippet)" :loading="snippetLoading[snippet.name]">
            {{ snippet.name }}
          </v-btn> -->

          <v-btn v-for="snippet in getWidgetDefinition(widget.name)?.snippets || []" :key="snippet.name"
            @click.stop="runSnippet(snippet)" :loading="snippetLoading[snippet.name]">
            {{ snippet.name }}
            <v-menu offset-y>
              <template v-slot:activator="{ props }">
                <v-icon large class="ml-2" v-bind="props">mdi-menu-down</v-icon>
              </template>
              <v-list>
                <v-list-item v-for="client in listnerNames" :key="client"
                  @click="sendSnippet(snippet, client)"
                >
                {{ client }}
                </v-list-item>
              </v-list>
            </v-menu>
          </v-btn>
          <!--
          <div v-for="snippet in getWidgetDefinition(widget.name)?.snippets || []" :key="snippet.name" class="d-inline mr-2">

            <v-btn @click.stop="runSnippet(snippet)" :loading="snippetLoading[snippet.name]">
              {{ snippet.name }}
            </v-btn>
            <v-menu offset-y>
              <template v-slot:activator="{ props }">
                <div v-bind="props" class="d-inline">
                    <v-icon >mdi-menu-down</v-icon>
                </div>
              </template>
              <v-list>
                <v-list-item>TEST</v-list-item>
              </v-list>
            </v-menu>

          </div>
        -->

        </div>


      </v-col>
    </v-row>

  </div>
</template>

<style scoped>
.bubble {
  font-weight: bold;
  border: 1px solid;
  padding: 0px 5px;
  border-radius: 5px;
}

.bubble-gray {
  color: gray;
  border: 1px solid gray;
}

.bubble-narrow {
  padding: 0px;
}

.border-right {
  border-right: 1px solid lightgray;
}
</style>

<script lang="ts" setup>

import { type BrodcastMsg } from '~/composables/useProcesses';
import { parseLuaObject } from '~/lib/parser';
import type { Snippet } from '~/models/widgets';
import { getWidgetDefinition } from '~/widgets/';
import type { StoredWidget } from '~/store/persist';

const props = defineProps<{
  pid: string;
}>();

const proc = useProcess<any>(props.pid);
proc.addListener({ client: 'Parser', handler: listen });

const listnerNames = computed(() => {
  return proc.getListenerNames();
});

const processName = computed(() => {
  if (props.pid === proc.name.value || !proc.name.value) return props.pid;
  return `${props.pid} - ${proc.name.value}`;
});

const snippetLoading = reactive<Record<string, boolean>>({});

const maxColumns = computed(() => {
  return Math.max(...proc.widgets.value.map((widget) => {
    return widget.column || 1;
  }));
});

function listen(text: BrodcastMsg[]) {
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
    // console.log('running dry run: ', snippet);
    const res = await proc.rundry(snippet.pid, snippet.tags, snippet.data);
    snippetLoading[snippet.name] = false;
    // console.log('dry run res:', res);
    return res;
  }

  if (!snippet.data) return undefined;

  snippetLoading[snippet.name] = true;
  // console.log('running data: ', snippet);
  const res = await proc.command(snippet.data);
  snippetLoading[snippet.name] = false;
  // console.log('command res:', res);
  return res;

}

function sendSnippet(snippet: Snippet, client: string) {
  proc.broadcast([{ data: snippet.data || '', tags: [], type: 'internal' }], client);
}


function process(output: string) {

  proc.widgets.value.forEach((widget) => {
    const wd = getWidgetDefinition(widget.name);
    if (!wd) {
      console.error(`No widget definition found for ${widget.name}`);
      proc.removeWidget(widget.name);
      return;
    }

    wd.parsers.forEach((parser) => {
      if (parser.mode === 'store') {
        const object = parseLuaObject(output);
        if (!object) return;
        const variable = parser.variable as any;
        const zodType = (wd.types as any)[variable];
        if (!zodType) throw new Error(`No type found for ${variable}`);
        const parsed = zodType.safeParse(object);
        if (parsed.success) {
          proc.setStateVariable(wd.name, variable, parsed.data);
        }
      }

    });

  });

}

function moveLeft(widget: StoredWidget) {
  widget.column = Math.max((widget.column || 1) - 1, 1);
}

function moveRight(widget: StoredWidget) {
  widget.column = (widget.column || 1) + 1;
}

function moveUp(widget: StoredWidget) {
  const widgets = proc.widgets.value;
  const ourColumn = widgets.filter((w) => (w.column || 1) === (widget.column || 1));
  if (ourColumn.length < 2) return;

  const ourColumnIndex = ourColumn.findIndex((w) => w.name === widget.name);
  if (ourColumnIndex === 0) return;

  const upperNeighbour = ourColumn[ourColumnIndex - 1];
  const upperNeighbourGlobalIndex = widgets.findIndex((w) => w.name === upperNeighbour.name);
  const ourGlobalIndex = widgets.findIndex((w) => w.name === widget.name);

  widgets.splice(upperNeighbourGlobalIndex, 0, widgets.splice(ourGlobalIndex, 1)[0]);

  proc.replaceWidgets(widgets);
}

function moveDown(widget: StoredWidget) {
  const widgets = proc.widgets.value;
  const ourColumn = widgets.filter((w) => (w.column || 1) === (widget.column || 1));
  if (ourColumn.length < 2) return;

  const ourColumnIndex = ourColumn.findIndex((w) => w.name === widget.name);
  if (ourColumnIndex === ourColumn.length - 1) return;

  const lowerNeighbour = ourColumn[ourColumnIndex + 1];
  const lowerNeighbourGlobalIndex = widgets.findIndex((w) => w.name === lowerNeighbour.name);
  const ourGlobalIndex = widgets.findIndex((w) => w.name === widget.name);

  widgets.splice(ourGlobalIndex, 0, widgets.splice(lowerNeighbourGlobalIndex, 1)[0]);

  proc.replaceWidgets(widgets);
}

</script>
~/composables/useProcesses~/models/widgets~/widgets/utils~/widgets/arena