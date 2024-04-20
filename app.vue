<template>
  <v-app :theme="persist.theme">
    <VSonner position="top-center" />
   
    <v-app-bar app>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />
      
      <v-tabs v-model="currentPid">
        <v-tab v-for="proc in running" :key="proc.pid" :value="proc.pid">
          {{ shortenCutMiddle(proc.name, 10) }}
        </v-tab>
      </v-tabs>

      <v-spacer />

      <Popup />

      <v-btn icon @click="persist.toggleTheme">
        <v-icon>{{ persist.theme === 'dark' ? 'mdi-white-balance-sunny' : 'mdi-moon-waning-crescent' }}</v-icon>
      </v-btn>

    </v-app-bar>

    <v-navigation-drawer v-model="drawer" :temporary="false">

      <ProcessesMenu v-model="currentPid" :processes="running" />

      <v-list>
        <v-list-item>
          <v-icon start>mdi-github</v-icon>
          <NuxtLink to="https://github.com/tsol/aos-wd">GitHub</NuxtLink>
        </v-list-item>
      </v-list>

    </v-navigation-drawer>
    <v-main>

      <About v-if="!currentPid" />

      <div class="ma-md-4" v-else>
        <v-window v-model="currentPid">
          <v-window-item v-for="proc in running" :key="proc.pid" :value="proc.pid">

            <WidgetDesk :pid="proc.pid" />

          </v-window-item>
        </v-window>
      </div>
 
    </v-main>
  </v-app>
</template>

<script lang="ts" setup>
import { usePersistStore } from './store/persist';
import { shortenCutMiddle } from './lib/utils';
import { VSonner } from 'vuetify-sonner';

const persist = usePersistStore();

const drawer = ref(false);

const currentPid = computed({
  get: () => persist.currentPid,
  set: (pid) => persist.setCurrentPid(pid),
});

const persistStore = usePersistStore();

const running = computed(() => {

  const runningPids = useProcesses().running.value?.map((p) => p.pid);
  return persistStore.processes.filter((p) => runningPids?.includes(p.pid));

});

watch(currentPid, (pid) => {
  if (!pid) return;
  // TODO: move this to persist itself
  usePersistStore().updateProcessDefaultWidgets(pid);
}, { immediate: true });


</script>