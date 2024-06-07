<template>
  <div>
    <div class="mb-2 d-flex align-center">

      <v-btn @click="process.command(code)" color="primary" class="mr-2" :disabled="!code">
        <v-icon>mdi-play</v-icon>
      </v-btn>

      <v-btn @click="process.command(selection)" color="primary" class="mr-2" :disabled="!selection">
        <template #prepend>
          <v-icon>mdi-play</v-icon>
        </template>
        {{ mdAndUp ? 'Selected' : 'Sel' }}
      </v-btn>


      <v-spacer></v-spacer>

      <v-btn v-if="lastSender" @click="updateSnippet()" color="primary" class="mr-2">
        <template #prepend>
          <v-icon>mdi-content-save-move</v-icon>
        </template>
        {{
        //shortenCutMiddle(lastSender, mdAndUp ? 30 : 15)
        mdAndUp ?
          shortenCutMiddle(lastSender, 30) :
          shortenCutMiddle(lastSender.split(':').findLast(() => true) || '', 15)
      }}
      </v-btn>

      <load-blueprint-dialog @loaded="code = $event" v-slot="props">
        <v-btn v-bind="props" color="primary">
          <v-icon>
            mdi-github
          </v-icon>
        </v-btn>
      </load-blueprint-dialog>

    </div>
    <code-editor v-model="code" @onSelected="selection = $event?.text"></code-editor>
  </div>
</template>

<script lang="ts" setup>
import { useDisplay } from 'vuetify';
import { shortenCutMiddle } from '~/lib/utils';

const cProps = defineProps<{
  pid: string;
}>();

const { mdAndUp } = useDisplay();

const process = useProcess(cProps.pid);

const code = ref(`Handlers.list`);
const selection = ref('');
const lastSender = ref('');

process.addListener({ client: 'IDE', handler: listen });

function listen(text: BrodcastMsg[]) {
  const internal = text.filter((msg) => msg.type === 'internal');
  if (!internal.length) return;
  const lastMsg = internal[internal.length - 1];
  lastSender.value = lastMsg?.fromClient || '';
  code.value = lastMsg?.data;
}

function updateSnippet() {

  if (!lastSender.value.includes(':')) return;
  const [widgetName, snippetName] = lastSender.value.split(':');

  const widget = process.widgets.value?.find((w) => w.name === widgetName);
  if (!widget) throw new Error('Widget not found');

  const snippet = widget.snippets?.find((s) => s.name === snippetName);
  if (!snippet) throw new Error('Snippet not found');

  snippet.data = code.value;

}

</script>
