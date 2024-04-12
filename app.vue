<template>
  <v-app>
    <v-app-bar app>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />
      <v-tabs v-model="usePersistStore().currentPid">
          <v-tab v-for="proc in running" :key="proc.pid" :value="proc.pid">
            {{ shortenCutMiddle(proc.name, 10) }}
          </v-tab>
        </v-tabs>
      <v-spacer />
      <Popup />
    </v-app-bar>

    <v-navigation-drawer v-model="drawer" :temporary="false">
      <v-list>
        <v-list-item title="Menu item" />
      </v-list>
    </v-navigation-drawer>
    <v-main>
      <v-container>

        <v-window v-model="usePersistStore().currentPid">
          <v-window-item v-for="proc in running" :key="proc.pid" :value="proc.pid">

            <PacksProcessor :pid="proc.pid" />
            <Console :pid="proc.pid" />

          </v-window-item>
        </v-window>

      </v-container>
    </v-main>
  </v-app>
</template>

<script lang="ts" setup>
import { usePersistStore } from './store/persist';
import { shortenCutMiddle } from './lib/utils';

const drawer = ref(false);

const running = computed(() => {

  const pids = useProcesses().running.value?.map((p) => p.pid);
  return usePersistStore().getProcesses.filter((p) => pids?.includes(p.pid));

});



</script>