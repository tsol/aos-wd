<template>
  <div :class="maxColumns > 1 ? undefined : 'v-container'">

    <div class="d-flex align-center mb-4">
      <add-widget :pid="pid" v-slot="{ props }">
        <div v-bind="props" class="text-caption bubble text-no-wrap text-success">Add Widget</div>
      </add-widget>
      <v-divider class="ml-2 mr-2"></v-divider>
      <div class="text-caption bubble bubble-gray text-no-wrap">
        <ClickToClipboard :value="pid">
          {{ shortenCutMiddle(pid, mdAndUp ? 30 : 9 ) }}
        </ClickToClipboard>
      </div>
      <v-divider class="ml-2 mr-2"></v-divider>

      <ProcessContextMenu :pid="pid" v-slot="pProps">
        <v-icon v-bind="pProps" size="small" color="green" class="bubble my-float-left">mdi-dots-horizontal</v-icon>
      </ProcessContextMenu>

    </div>

    <v-row>

      <!-- <v-col v-for="column in maxColumns" :key="column" :class="`v-col-md-${12 / maxColumns}`"> -->
      <v-col v-for="(column, index) in maxColumns" :key="column"
        :class="`v-col-md-${12 / maxColumns} ${index < maxColumns - 1 ? 'border-right' : ''}`">

        <div v-for="widget in process.widgets.value.filter((w) => (w.column || 1) === column)" :key="widget.name"
          class="mb-6">

          <div class="d-flex align-center mb-4 text-grey">
            <div class="text-caption bubble">{{ widget.name }}</div>
            <v-divider class="ml-2 mr-2"></v-divider>
            <v-icon size="small" class="bubble mr-1" @click="moveLeft(widget)">mdi-arrow-left</v-icon>
            <v-icon size="small" class="bubble mr-1" @click="moveDown(widget)">mdi-arrow-down</v-icon>
            <v-icon size="small" class="bubble mr-1" @click="moveUp(widget)">mdi-arrow-up</v-icon>
            <v-icon size="small" class="bubble mr-1" @click="moveRight(widget)">mdi-arrow-right</v-icon>
            <v-icon size="small" color="red" class="bubble"
              @click="process.removeWidget(widget.name)">mdi-close</v-icon>
          </div>

          <Component :is="getWidgetDefinition(widget.name)?.component" :pid="pid"
            :state="(process.state.value as any)?.[widget.name]" />

          <div class="mt-2">
            <v-btn v-for="snippet in widget.snippets || []" :key="snippet.name" @click.stop="runSnippet(snippet)"
              :loading="snippetLoading[snippet.name]">
              {{ shortenCutMiddle(snippet.name, 30) }}
              <SnippetFormDialog
                :pid="pid"
                :snippet="snippet" :widgetName="widget.name" :snippetsTimer="snippetsTimer"
                v-model="snippetMenu[snippetID(snippet)]" />
            </v-btn>


            <v-btn @click="createSnippet(widget.name)" color="success">
              <v-icon>mdi-plus</v-icon>
            </v-btn>
          </div>

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
import type { StoredSnippet, StoredWidget } from '~/store/persist';
import { getWidgetDefinition } from '~/widgets/';
import { shortenCutMiddle } from '~/lib/utils';
import { useDisplay } from 'vuetify';

const { mdAndUp } = useDisplay();

const props = defineProps<{
  pid: string;
}>();

const process = useProcess<any>(props.pid);
const snippetsTimer = useSnippetsTimer(process);

process.addListener({ client: 'Parser', handler: listen });

const { snippetLoading, snippetMenu, runSnippet, snippetID } = useSnippets(process);

// const processName = computed(() => {
//   let res = '';
//   if (props.pid === process.name.value || !process.name.value) res = props.pid;
//   else res = `${props.pid} - ${process.name.value}`;
//   return shortenCutMiddle(res, mdAndUp.value ? 40 : 15);
// });


const maxColumns = computed(() => {
  return Math.max(...process.widgets.value.map((widget) => {
    return widget.column || 1;
  }));
});

function listen(text: BrodcastMsg[]) {
  if (!text.length) return;
  text.forEach((msg) => {
    parseProcess(msg.data);
  });
}

onUnmounted(() => {
  snippetsTimer.onUnmounted();
  process.removeListener(listen);
});


function createSnippet(widgetName: string) {
  
  const widget = process.widgets.value.find((w) => w.name === widgetName);
  if (!widget) throw new Error(`No widget found for ${widgetName}`);

  const name = (index: number) => `New Snippet ${index}`;
  const exists = (index: number) => widget.snippets?.find((s) => s.name === name(index));

  const newName: (index?: number) => string = (index = 1) => {
    if (!exists(index)) return name(index);
    return newName(index + 1);
  };

  const snippet: StoredSnippet = {
    name: newName(),
    data: '-- New Snippet\r\nHandlers.list',
  };

  // console.log('createSnippet', snippet);

  process.addSnippet(widgetName, snippet);

}

function parseProcess(output: string) {

  process.widgets.value.forEach((widget) => {
    const wd = getWidgetDefinition(widget.name);
    if (!wd) {
      console.error(`No widget definition found for ${widget.name}`);
      process.removeWidget(widget.name);
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
          process.setStateVariable(wd.name, variable, parsed.data);
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
  const widgets = process.widgets.value;
  const ourColumn = widgets.filter((w) => (w.column || 1) === (widget.column || 1));
  if (ourColumn.length < 2) return;

  const ourColumnIndex = ourColumn.findIndex((w) => w.name === widget.name);
  if (ourColumnIndex === 0) return;

  const upperNeighbour = ourColumn[ourColumnIndex - 1];
  const upperNeighbourGlobalIndex = widgets.findIndex((w) => w.name === upperNeighbour.name);
  const ourGlobalIndex = widgets.findIndex((w) => w.name === widget.name);

  widgets.splice(upperNeighbourGlobalIndex, 0, widgets.splice(ourGlobalIndex, 1)[0]);

  process.replaceWidgets(widgets);
}

function moveDown(widget: StoredWidget) {
  const widgets = process.widgets.value;
  const ourColumn = widgets.filter((w) => (w.column || 1) === (widget.column || 1));
  if (ourColumn.length < 2) return;

  const ourColumnIndex = ourColumn.findIndex((w) => w.name === widget.name);
  if (ourColumnIndex === ourColumn.length - 1) return;

  const lowerNeighbour = ourColumn[ourColumnIndex + 1];
  const lowerNeighbourGlobalIndex = widgets.findIndex((w) => w.name === lowerNeighbour.name);
  const ourGlobalIndex = widgets.findIndex((w) => w.name === widget.name);

  widgets.splice(ourGlobalIndex, 0, widgets.splice(lowerNeighbourGlobalIndex, 1)[0]);

  process.replaceWidgets(widgets);
}

</script>
~/composables/useProcesses~/models/widgets~/widgets/utils~/widgets/arena