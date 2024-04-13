<template>
  <v-menu offset-y>
    <!-- <template v-slot:activator="{ on, attrs }">
      <v-btn v-bind="attrs" v-on="on">Add Widget</v-btn>
    </template> -->
    <template v-slot:activator="{ props }">
      <slot :props="props"></slot>
    </template>
    <v-list>
      <v-list-item v-for="widget in widgets" :key="widget.name" @click="addWidget(widget)">
        <v-list-item-title>
          {{ widget.name }}
        </v-list-item-title>
      </v-list-item>
    </v-list>
  </v-menu>
</template>

<script lang="ts" setup>
import { useProcess } from '~/composables/useProcess';
import type { WidgetDefinition } from '~/models/widgets';

import { widgets } from '~/widgets';

const props = defineProps<{
  pid: string;
}>();

const proc = useProcess<any>(props.pid);
const dialog = ref(false);

function addWidget(widget: WidgetDefinition<any>) {
  proc.addWidget({ name: widget.name });
  dialog.value = false;
}

</script>
