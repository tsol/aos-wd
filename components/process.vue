<script lang="ts" setup>
import { shortenCutMiddle } from '~/lib/utils';
import { usePersistStore, type Process } from '~/store/persist';
import { useAO } from "~/composables/useAO";
import { useDisplay } from 'vuetify';
const ao = useAO();

const { xs } = useDisplay();

const editNameDialog = ref(false);
const width = computed(() => (xs.value ? undefined : 600));

const loading = ref(false);
const open = ref(false);
const shake = ref(false);

const shortPid = computed(() => shortenCutMiddle(usePersistStore().pid || '', 15));
const pid = computed(() => usePersistStore().pid || '');

const editedName = ref('');
const processName = computed({

  get: () => shortenCutMiddle(usePersistStore().current?.name || '', 30),
  set: (val: string) => {
    editedName.value = val;
  }

});

const label = computed(() => {
  if (usePersistStore().pid && shortPid.value) {
    return shortPid.value;
  }
  return 'Not connected';
});

const selectedProcess = ref<string | Process | undefined>(usePersistStore().current);
const connected = ao.online;

watch(() => usePersistStore().pid, () => {
  selectedProcess.value = usePersistStore().current;
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

const isSelectedAProcess = computed(() => !!selectedProcessPid.value);

const isSelectedCurrent = computed(() => {
  return usePersistStore().pid && selectedProcessPid.value === usePersistStore().pid;
});

const processes = computed( () => usePersistStore().processes);

async function doRegister() {
  if (!selectedProcess.value) return;
  if (typeof selectedProcess.value !== 'string') return;
  loading.value = true;
  await ao.newProcess(selectedProcess.value);
  loading.value = false;
}

async function doConnect() {
  if (!selectedProcess.value) return;
  if (!isSelectedAProcess) return;
  const pid = typeof selectedProcess.value === 'string' ? selectedProcess.value : selectedProcess.value.pid;
  loading.value = true;
  ao.connect(pid, selectedProcessName.value);
  loading.value = false;
}

async function doLogout() {
  loading.value = true;
  await ao.disconnect();
  loading.value = false;
}

function saveProcessName() {
  console.log('saveProcessName', editedName.value);
  editNameDialog.value = false;
  if (editedName.value) {
    usePersistStore().updateCurrentName(editedName.value);
  }
}

function copyCurrentPidToClipboard() {
  navigator.clipboard.writeText(usePersistStore().pid || '');
  shake.value = true;
  setTimeout(() => shake.value = false, 500);
}

</script>

<template>
  <v-menu v-model="open" :close-on-content-click="false">
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
        <v-list-item v-if="shortPid">
          <template #prepend>
            <v-icon size="x-large" class="bg-blue rounded">mdi-account</v-icon>
          </template>
          <template #title>

            <span v-if="!editNameDialog" @click="editNameDialog = true">
              {{ processName }}
              <v-icon size="x-small" color="grey" class="ml-2">mdi-pencil-box-outline</v-icon>
            </span>

            <v-text-field v-else v-model="processName" density="compact" variant="underlined" :hide-details="true">
              <template #append-inner>
                  <v-icon color="error" size="small" @click="editNameDialog = false">mdi-close</v-icon>
                  <v-icon color="success" size="small" @click="saveProcessName">mdi-check</v-icon>
              </template>
            </v-text-field>

          </template>
          <template #subtitle>
            <!-- Here copy to clipboard icon and onclick event to copy fullPid to clipboard -->
            <div :class="shake ? 'shake' : undefined" @click="copyCurrentPidToClipboard">
            {{ pid }}
            <v-icon size="x-small" color="grey" class="ml-2">mdi-content-copy</v-icon>
           </div>
          </template>
        </v-list-item>
        <v-list-item v-else>
          <v-list-item-title>Process not connected</v-list-item-title>
        </v-list-item>
      </v-list>

      <v-divider class="my-4" />

      <v-combobox label="A process ID or process name"
        hint="Select a process to connect to or enter name to create a new one." v-model="selectedProcess"
        :items="processes" :return-object="true" item-title="name" item-value="pid" clearable
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

        <v-btn color="primary" variant="elevated" :disabled="isSelectedCurrent || !isSelectedAProcess"
          @click="doConnect" :loading="loading">
          Connect
        </v-btn>

        <v-btn color="primary" variant="elevated"
          :disabled="isSelectedCurrent || isSelectedAProcess || !selectedProcessName" @click="doRegister"
          :loading="loading">
          Create
        </v-btn>

        <v-btn color="error" :disabled="!connected" variant="elevated" @click="doLogout()" :loading="loading">
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
</style>