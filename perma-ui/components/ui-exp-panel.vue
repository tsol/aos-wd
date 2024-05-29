<!-- wrap for v-expansion-panels + v-expansion-pannel -->
<template>
  <v-expansion-panels>
    <v-expansion-panel>
      <v-expansion-panel-title>
        <slot name="title">{{ title }}</slot>
      </v-expansion-panel-title>
      <v-expansion-panel-text>
        <slot />
      </v-expansion-panel-text>
    </v-expansion-panel>
  </v-expansion-panels>
</template>

<script lang="ts" setup>

const props = defineProps<{
  title: string
}>()

</script>
