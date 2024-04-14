<template>

  <v-dialog v-model="snippetMenu" :style="mdAndUp ? 'max-width: 80%' : undefined">
    <template v-slot:activator="{ props }">
      <slot v-bind="props">
        <v-icon large class="ml-2" v-bind="props">mdi-menu-down</v-icon>
      </slot>
    </template>
    <v-card>

      <v-card-text>
        <div class="d-flex text-caption">
        <div>Snippet: <b>{{ snippet.name }}</b></div>
        <v-spacer></v-spacer>
        <span @click="snippetMenu = false">
          <v-icon size="x-small" color="red">mdi-close</v-icon>
        </span>
      </div>
        <code-editor v-model="snippet.data" style="height: 200px; width: 100%;" class="mb-6">
        </code-editor>
        <div class="d-flex flex-column flex-md-row justify-space-between">
          <!-- class="w-md-50 mr-md-4 mb-4 flex-grow" -->
          <div :class="`flex-grow mr-md-4 mb-4 ${ mdAndUp ? 'w-50' : 'w-100' }`">
            <VarsForm :pid="pid" :variables="variablesList" />
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
}>();


const emit = defineEmits<{
  (event: 'update:modelValue', value: boolean): void,
}>();

const { mdAndUp } = useDisplay();

const process = useProcess(props.pid);

const { runSnippet, snippetLoading } = useSnippets(process);

const snippetMenu = ref(props.modelValue);
const variablesList = ref<string[]>([]);
const sendTo = ref('');

const listners = computed(() => {
  return process.getListenerNames()?.map( (l) => ({ value: l, title: l }) );
});

watch( listners, () => {
  if (! listners.value || !listners.value.length ) return;
  if ( sendTo.value ) return;

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
  snippetMenu.value = value;
});

watch(() => snippetMenu.value, (value) => {
  emit('update:modelValue', value);
});

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
