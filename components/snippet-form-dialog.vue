<template>

  <v-dialog v-model="dialogOpen" :style="mdAndUp ? 'max-width: 80%' : undefined">
    <template v-slot:activator="{ props }">
      <slot v-bind="props">
        <v-icon large class="ml-2" v-bind="props">mdi-menu-down</v-icon>
      </slot>
    </template>
    <v-card>

      <v-card-text>
        <div class="d-flex justify-space-between mb-2">
        <EditableField :value="snippet.name" @changed="doRenameSnippet"/>
        <v-menu offset-y>
          <template v-slot:activator="{ props }">
            <v-icon v-bind="props">mdi-dots-horizontal</v-icon>
          </template>
          <v-list>
            <v-list-item @click="dialogOpen = false">
              <v-list-item-title>Close Snippet</v-list-item-title>
            </v-list-item>
            <v-list-item @click="process.removeSnippet(widgetName, snippet.name)">
              <v-list-item-title>Remove Snippet</v-list-item-title>
            </v-list-item>
          </v-list>
        </v-menu>
      </div>
        <code-editor v-if="snippet.data !== undefined && snippet.data !== null"
          v-model="snippet.data" style="height: 200px; width: 100%;" class="mb-6">
        </code-editor>
        <div class="d-flex flex-column flex-md-row justify-space-between">
          <!-- class="w-md-50 mr-md-4 mb-4 flex-grow" -->
          <div :class="`flex-grow mr-md-4 mb-4 ${ mdAndUp ? 'w-50' : 'w-100' }`">
            <VarsForm :pid="pid" :variables="variablesList" />
          </div>
          <div>

            <v-select
              style="min-width: 100px; flex-shrink: 0;"
              :class="mdAndUp ? 'mb-4' : 'mr-4'"
              v-model="selectedInterval"
              :items="snippetIntervals"
              label="Local timer"
              density="compact"
              hideDetails
              variant="outlined"
              @update:model-value="changeTimer($event)"
            >
            </v-select>

          </div>
          <div>
            <div class="d-flex justify-space-between">
            <v-btn
              @click="runSnippet(snippet)"
              color="primary"
              size="large"
              class="mr-2"
              :loading="snippetLoading[snippet.name]"
            >
                <v-icon>mdi-play</v-icon>
            </v-btn>
            <div class="d-flex">
              <v-select
                style="min-width: 50px; flex-shrink: 0;"
                class="mr-2"
                v-model="sendTo"
                :items="listners"
                density="compact"
                hideDetails
                variant="outlined"
              >
              </v-select>
              <v-btn
                v-if="sendTo"
                @click="sendSnippet"
                size="large"
                color="primary"
                variant="outlined"
              >
                  <v-icon>mdi-arrow-right</v-icon>
              </v-btn>
            </div>
            </div>
          </div>
        </div>
      </v-card-text>
    </v-card>
  </v-dialog>

</template>
<!-- <style scoped>
.v-dialog {
  overflow-y: hidden !important
}
</style> -->
<script lang="ts" setup>
import type { StoredSnippet } from '~/store/persist';
import { extractTemplateVariables } from '~/lib/utils';

import { debounce } from 'lodash';
import { useDisplay } from 'vuetify';

const props = defineProps<{
  modelValue: boolean | undefined;
  pid: string;
  snippet: StoredSnippet;
  widgetName: string;
  snippetsTimer: ReturnType<typeof useSnippetsTimer>;
}>();


const emit = defineEmits<{
  (event: 'update:modelValue', value: boolean): void,
}>();

const { mdAndUp } = useDisplay();

const dialogOpen = computed({
  get: () => props.modelValue || false,
  set: (val: boolean) => {
    emit('update:modelValue', val);
  }
});

const process = useProcess(props.pid);

const { runSnippet, snippetLoading, snippetMenu , snippetID } = useSnippets(process);

const variablesList = ref<string[]>([]);
const sendTo = ref('');

const listners = computed(() => {
  return process.getListenerNames()?.map( (l) => ({ value: l, title: l }) );
});

const snippetIntervals = [
  { title: 'none', value: 0 },
  { title: '10-seconds', value: 10000 },
  { title: '30-seconds', value: 30000 },
  { title: '1-minute', value: 60000 },
  { title: '5-minutes', value: 300000 },
  { title: '10-minutes', value: 600000 },
  { title: '30-minutes', value: 1800000 },
  { title: '1-hour', value: 3600000 },
];

const selectedInterval = ref(props.snippet.runInterval || 0);

watch( listners, () => {
  if (! listners.value || !listners.value.length ) return;

  if (listners.value.find( (v) => v.value === 'IDE')){
    sendTo.value = 'IDE';
    return;
  }
  
  sendTo.value = listners.value[0].value;
  
}, { immediate: true, deep: true });


const updateVariables = debounce(() => {
  variablesList.value = extractTemplateVariables(props.snippet.data);
}, 1000, { leading: false, trailing: true });

watch(() => props.snippet.data, () => {
  updateVariables();
}, { immediate: true });

watch(() => props.modelValue, (value) => {
  dialogOpen.value = value;
});

// watch(() => snippetMenu.value, (value) => {
//   emit('update:modelValue', value);
// });

function changeTimer(interval: number) {
  if (interval === 0 || !interval) {
    props.snippetsTimer.stopSnippetTimer(props.snippet);
    useToast().ok('Snippet timer stopped');
  } else {
    props.snippetsTimer.stopSnippetTimer(props.snippet);
    const errMsg = props.snippetsTimer.startSnippetTimer(props.snippet, interval);
    if (errMsg) {
      useToast().error(errMsg);
    } else {
      useToast().ok('Snippet timer started');
    }
  }
}

function doRenameSnippet(name: string) {
  const oldSnip = { ... props.snippet };
  snippetMenu[snippetID(props.snippet)] = snippetMenu[snippetID(oldSnip)];
  props.snippet.name = name;
  emit('update:modelValue', true);
}

function sendSnippet() {
  const snippet = props.snippet
  const client = sendTo.value;
  const from = `${props.widgetName}:${snippet.name}`;

  process.broadcast([{
    data: snippet.data || '',
    tags: [],
    type: 'internal',
    fromClient: from,
  }], client);
}

</script>
