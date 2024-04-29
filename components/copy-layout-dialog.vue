<template>
  <v-dialog v-model="copyDialog" max-width="500px">
    <v-card>
      <v-card-title>Copy widget layout and snippets code</v-card-title>
      <v-card-text>
        <div class="text-caption">Select a process to copy data to.</div>
        <select-process v-model="selectedPid" label="Select process" />
      </v-card-text>
      <v-card-actions>
        <v-btn @click="copyDialog = false">Cancel</v-btn>
        <v-btn @click="doCopy" :disabled="!pid || selectedPid === pid || !selectedPid">Copy</v-btn>
      </v-card-actions>
    </v-card>
  </v-dialog>
</template>

<script lang="ts" setup>
import { usePersistStore } from '~/store/persist';

const props = defineProps<{
  pid: string;
  modelValue: boolean;
}>();

const emit = defineEmits<{
  (event: 'update:modelValue', value: boolean): void,
}>();

const processes = useProcesses();
const persist = usePersistStore();

const selectedPid = ref<string | undefined>(undefined);

const copyDialog = computed({
  get: () => props.modelValue || false,
  set: (val: boolean) => {
    emit('update:modelValue', val);
  }
});

async function doCopy() {
  if (selectedPid.value) {
    console.log('Copying layout and data to process ' + selectedPid.value);
    processes.disconnect(selectedPid.value);
    setTimeout(finishCopy, 1000);
  }
}

function finishCopy() {
  if (!selectedPid.value) {
    useToast().error('No process selected');
    return;
  }

  if (persist.cloneProcess(props.pid, selectedPid.value)) {
    processes.connect(selectedPid.value);
    useToast().ok('Layout and data copied to process ' + selectedPid.value);
  }
  else
    useToast().error('Failed to copy layout and data to process ' + selectedPid.value);
  
  copyDialog.value = false;
}

</script>
