<template>

  <v-dialog v-model="dialogOpen" :style="mdAndUp ? 'max-width: 80%' : undefined">
    <template v-slot:activator="{ props }">
      <slot v-bind="props">
        <v-icon large class="ml-2" v-bind="props">mdi-menu-down</v-icon>
      </slot>
    </template>
    <v-card>
      <v-card-text>

        <v-tabs v-model="tabValue">
          <v-tab v-for="(repo) in blueprints.repos.value" :value="repo.name">
            {{ repo.title }}
          </v-tab>
        </v-tabs>

        <v-window v-model="tabValue" class="mt-4">
          <v-window-item v-for="(repo) in blueprints.repos.value" :value="repo.name">

            <v-progress-linear v-if="!repo.fetched" indeterminate></v-progress-linear>
            <v-alert v-if="repo.error" type="error">
              {{ repo.error }}
            </v-alert>
            <div v-else>
              <v-btn v-for="(file) in repo.files" :key="file" @click="doLoad(repo.name, file)" variant="outlined">
                <template #prepend>
                  <v-icon>mdi-file</v-icon>
                </template>
                {{ file }}
              </v-btn>
            </div>
          </v-window-item>
        </v-window>

      </v-card-text>
    </v-card>
  </v-dialog>

</template>
<script lang="ts" setup>
import { useDisplay } from 'vuetify';
import { useBlueprints } from '~/composables/useBlueprints';

const blueprints = useBlueprints();
const { mdAndUp } = useDisplay();
const emit = defineEmits<{
  (event: 'loaded', value: string): void,
}>();

const dialogOpen = ref(false);
const tabValue = ref('aos');

watch(tabValue, () => {
  if (!tabValue.value) return;
  blueprints.list(tabValue.value);
}, { immediate: true });

async function doLoad(repo: string, file: string) {
  const res = await blueprints.load(file, repo);
  if (!res) throw new Error('Failed to load blueprint');
  emit('loaded', res);
  dialogOpen.value = false;
}

</script>