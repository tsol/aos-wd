<script lang="ts" setup>
import { shortenCutMiddle } from '~/lib/utils';
import { usePersistStore, type Process } from '~/store/persist';
import { useProcesses } from "~/composables/useProcesses";
import { useDisplay } from 'vuetify';
import { processesList } from '~/lib/ao/query';

const persist = usePersistStore();
const ao = useProcesses();

const { xs } = useDisplay();
const width = computed(() => (xs.value ? undefined : 600));

const loading = ref(false);
const open = ref(false);

const selectedProcessPid = ref<string | undefined>(persist.currentPid);

const newProcessName = ref<string | undefined>();

const cronModes = ['none', '10-seconds', '1-minute', '5-minutes', '15-minutes', '30-minutes', '1-hour', '1-day'];
const selectedCronMode = ref<string | undefined>('none');

const monitoringChanging = ref(false);

const monitored = computed({
  get: () => selectedProcess.value?.monitored || false,
  set: (val: boolean) => {
    if (!selectedProcessPid.value) return;
    monitoringChanging.value = true;
    if (val) {
      
      useProcesses().monitor(selectedProcessPid.value)
        .then(() => {
          monitoringChanging.value = false;
        });
    }
    else {
      useProcesses().unmonitor(selectedProcessPid.value)
        .then(() => {
          monitoringChanging.value = false;
        });
    }
  }
});


function validPid(pid?: string) {
  return !!pid && pid?.length === 43;
}

function validNameExists(name?: string) {
  return !!persist.processes.find((p) => p.name === name);
}


const selectedProcess = computed(() => {
  return persist.processes.find((p) => p.pid === selectedProcessPid.value);
});

const selectedProcessName = computed(() => {
  return selectedProcess.value?.name;
});

const isSelectedCurrent = computed(() => {
  return persist.currentPid && selectedProcessPid.value === persist.currentPid;
});

const isSelectedRunning = computed(() => {
  return selectedProcess.value?.isRunning;
});

const label = computed(() => {
  if (persist.currentPid && persist.currentPid !== undefined) {
    return shortenCutMiddle(persist?.currentPid || '',
      xs.value ? 9 : 15
    );
  }
  return 'Not connected';
});

async function doRegister(name?: string) {

  if (validPid(name)) {
    await doConnect();
    return;
  }

  if (!name) {
    useToast().error('Please provide a name');
    return;
  }

  const cronMode = selectedCronMode.value === 'none' ? undefined : selectedCronMode.value;


  loading.value = true;
  const pid = await ao.newProcess(name, cronMode);

  if (!pid) {
    useToast().error('Failed to create new process');

    loading.value = false;
    return;
  }

  persist.setCurrentPid(pid);
  selectedProcessPid.value = pid;

  useToast().ok('Process created');

  loading.value = false;
}

async function doConnect() {
  const pid = selectedProcessPid.value;
  if (!pid) return;
  loading.value = true;
  ao.connect(pid, selectedProcessName.value);
  persist.setCurrentPid(pid);
  selectedProcessPid.value = pid;
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
}


function onDialogStateChange(val: boolean) {
  if (val) {
    selectedProcessPid.value = persist.currentPid;
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
            <ClickToClipboard :value="selectedProcessPid" />
          </template>
        </v-list-item>
        <v-list-item v-else>
          <v-list-item-title>Process not selected</v-list-item-title>
        </v-list-item>
      </v-list>

      <v-divider class="my-4" />

      <SelectProcess v-model="selectedProcessPid" />

      <v-row class="align-center">
        <div class="v-col-md-6">

          <v-btn v-if="!isSelectedRunning" color="primary" variant="elevated" :disabled="isSelectedRunning"
            @click="doConnect" :loading="loading">
            Connect
          </v-btn>

          <v-btn v-else color="error" variant="elevated" @click="doLogout()" :loading="loading">
            Disconnect
          </v-btn>
        </div>
        <div class="v-col-md-6">
          <v-switch v-model="monitored" :loading="monitoringChanging"  :label="`Cron Monitor: ${ monitored ? 'ON' : 'OFF' }`" />
        </div>
      </v-row>


      <v-divider class="my-4" />

      <v-row>
        <v-text-field class="v-col-md-8" v-model="newProcessName" label="New process name"
          hint="Type new process name to create new process." />

        <v-select class="v-col-md-4" v-model="selectedCronMode" :items="cronModes" label="Cron mode"
          hint="Select cron mode for the process" clearable />
      </v-row>

      <v-btn color="primary" variant="elevated"
        :disabled="!newProcessName || validNameExists(newProcessName) || validPid(newProcessName)"
        @click="doRegister(newProcessName)" :loading="loading">
        Create
      </v-btn>


    </v-card>
  </v-menu>
</template>

~/composables/useProcesses