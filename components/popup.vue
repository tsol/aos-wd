<script lang="ts" setup>
import { shortenCutMiddle } from '~/lib/utils';
import { usePersistStore, type Process } from '~/store/persist';
import { useProcesses } from "~/composables/useProcesses";
import { useDisplay } from 'vuetify';

const persist = usePersistStore();
const ao = useProcesses();

const { xs } = useDisplay();
const width = computed(() => (xs.value ? undefined : 600));

const loading = ref(false);
const open = ref(false);
const shake = ref(false);

const selectedProcess = ref<string | Process | undefined>(persist.getCurrentProcess);

const label = computed(() => {
  if (persist.currentPid && persist.currentPid !== undefined) {
    return shortenCutMiddle(persist?.currentPid || '',
    xs.value ? 9 : 15
  );
  }
  return 'Not connected';
});

const selectedProcessName = computed(() => {
  if (typeof selectedProcess.value === 'string') {
    return selectedProcess.value;
  }
  return selectedProcess.value?.name;
});

const selectedProcessPid = computed(() => {
  const probablyPid = typeof selectedProcess.value === 'string' ? selectedProcess.value : selectedProcess.value?.pid;
  if (probablyPid?.length === 43) {
    return probablyPid;
  }
  return undefined;
});


const isSelectedCurrent = computed(() => {
  return persist.currentPid && selectedProcessPid.value === persist.currentPid;
});

const isSelectedAProcess = computed(() => !!selectedProcessPid.value);

const isSelectedRunning = computed(() => {
  const selectedProcess = persist.processes.find((p) => p.pid === selectedProcessPid.value);
  return selectedProcess?.isRunning;
});


async function doRegister() {
  if (!selectedProcess.value) {
    console.error('No process selected');
    return;
  }
  if (typeof selectedProcess.value !== 'string') {
    console.error('Input field is not a new process name, but an existing process object.');
    return;
  }

  loading.value = true;
  const pid = await ao.newProcess(selectedProcess.value);

  if (!pid) {
    console.error('Failed to create new process');
    loading.value = false;
    return;
  }

  persist.setCurrentPid(pid);
  selectedProcess.value = persist.processes.find((p) => p.pid === pid);

  loading.value = false;
}

async function doConnect() {
  const pid = selectedProcessPid.value;
  if (!pid) return;
  loading.value = true;
  ao.connect(pid, selectedProcessName.value);
  persist.setCurrentPid(pid);
  selectedProcess.value = persist.processes.find((p) => p.pid === pid);
  loading.value = false;
}

async function doLogout() {
  loading.value = true;
  if (selectedProcessPid.value) {
    await ao.disconnect(selectedProcessPid.value);
    persist.setCurrentPid(undefined);
  }
  loading.value = false;
}

function saveProcessName($event: string) {
  console.log('saveProcessName', $event);
  if (!$event) return;
  if (!selectedProcessPid.value) return;

  persist.updateName(selectedProcessPid.value, $event);

  selectedProcess.value = persist.processes.find((p) => p.pid === selectedProcessPid.value);
}

function copyCurrentPidToClipboard() {
  navigator.clipboard.writeText(persist.currentPid || '');
  shake.value = true;
  setTimeout(() => shake.value = false, 500);
}

function onDialogStateChange(val: boolean) {
  if (val) {
    selectedProcess.value = persist.getCurrentProcess;
  }
}

</script>

<template>
  <v-menu v-model="open" :close-on-content-click="false" @update:model-value="onDialogStateChange">
    <template #activator="{ props }">
      <div v-bind="props" class="d-flex align-center">

        <div>{{ label }}</div>
        <v-btn icon="mdi-arrow-down-circle" />
      </div>
    </template>

    <v-card class="pa-4" :width="width">

      <Wallet />
      <v-divider class="my-4" />

      <v-list>
        <v-list-item v-if="selectedProcessPid">
          <template #prepend>
            <v-icon size="x-large" class="bg-blue rounded">mdi-account</v-icon>
          </template>
          <template #title v-if="selectedProcessName">
            <editable-field :value="selectedProcessName" @changed="saveProcessName" />
          </template>
          <template #subtitle v-if="selectedProcessPid">
            <!-- Here copy to clipboard icon and onclick event to copy fullPid to clipboard -->
            <div :class="shake ? 'shake' : undefined" @click="copyCurrentPidToClipboard">
            {{ selectedProcessPid }}
            <v-icon size="x-small" color="grey" class="ml-2">mdi-content-copy</v-icon>
           </div>
          </template>
        </v-list-item>
        <v-list-item v-else>
          <v-list-item-title>Process not selected</v-list-item-title>
        </v-list-item>
      </v-list>

      <v-divider class="my-4" />

      <v-combobox label="A process ID or process name"
        hint="Select a process to connect to or enter name to create a new one." v-model="selectedProcess"
        :items="persist.processes" :return-object="true" item-title="name" item-value="pid" clearable
        @click:clear="console.log('clear')">
        <template #item="{ item, props }">
          <v-list-item v-bind="props" title="">
            <v-list-item-title>
              {{ item.raw.name }}
            </v-list-item-title>
            <v-list-item-subtitle>
              {{ item.raw.pid }}
            </v-list-item-subtitle>
          </v-list-item>
        </template>

      </v-combobox>


      <v-divider class="my-4" />

      <v-card-actions>
        <v-spacer />

        <v-btn color="primary" variant="elevated" :disabled="isSelectedRunning"
          @click="doConnect" :loading="loading">
          Connect
        </v-btn>

        <v-btn color="primary" variant="elevated"
          :disabled="isSelectedCurrent || isSelectedAProcess || !selectedProcessName" @click="doRegister"
          :loading="loading">
          Create
        </v-btn>

        <v-btn color="error" :disabled="!isSelectedRunning" variant="elevated" @click="doLogout()" :loading="loading">
          Disconnect
        </v-btn>
        <v-spacer />
      </v-card-actions>
    </v-card>
  </v-menu>
</template>

<style scoped>
.shake {
  animation: shake 0.5s;
}

@keyframes shake {
  0% { transform: translate(1px, 1px) rotate(0deg); }
  10% { transform: translate(-1px, -2px) rotate(-1deg); }
  20% { transform: translate(-3px, 0px) rotate(1deg); }
  30% { transform: translate(3px, 2px) rotate(0deg); }
  40% { transform: translate(1px, -1px) rotate(1deg); }
  50% { transform: translate(-1px, 2px) rotate(-1deg); }
  60% { transform: translate(-3px, 1px) rotate(0deg); }
  70% { transform: translate(3px, 1px) rotate(-1deg); }
  80% { transform: translate(-1px, -1px) rotate(1deg); }
  90% { transform: translate(1px, 2px) rotate(0deg); }
  100% { transform: translate(1px, -2px) rotate(-1deg); }
}
</style>~/composables/useProcesses