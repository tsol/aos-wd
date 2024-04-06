<template>
  <div class="d-flex flex-row">
      <v-text-field v-model="pid" />
      <v-btn 
        @click="doConnect">
        Connect to Process
      </v-btn>

      <v-text-field v-model="name" />
      <v-btn 
        @click="doRegister">
        create process
      </v-btn>

    </div>
</template>

<script lang="ts" setup>
import { usePersistStore } from "~/store/persist";
import { useAO } from "~/composables/useAO";
const ao = useAO();

const pid = ref('');
const name = ref('');

function doRegister() {
  ao.newProcess(name.value);
}

function doConnect() {
  console.log('connect to process', pid.value);
  ao.connect(pid.value);
}

</script>
