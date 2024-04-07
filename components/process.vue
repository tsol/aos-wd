<script lang="ts" setup>
import { shortenCutMiddle } from '~/lib/utils';
import { usePersistStore, type Process } from '~/store/persist';
import { useAO } from "~/composables/useAO";
import { useDisplay } from 'vuetify';
const ao = useAO();

const { xs } = useDisplay();

const width = computed(() => (xs.value ? undefined : 600));

const loading = ref(false);
const open = ref(false);

const shortPid = computed(() => shortenCutMiddle(usePersistStore().pid || '', 15));
const processName = computed(() => shortenCutMiddle(usePersistStore().current?.name || '', 30));

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

const processes = usePersistStore().processes;

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
          <v-list-item v-if="shortPid" :title="processName" :subtitle="shortPid">
            <template #prepend>
              <v-icon size="x-large" class="bg-blue rounded">mdi-account</v-icon>
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
            :disabled="isSelectedCurrent || isSelectedAProcess || !selectedProcessName" @click="doRegister" :loading="loading">
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
