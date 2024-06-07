<!-- wrap for v-expansion-panels + v-expansion-pannel -->
<template>
  <VExpansionPanels>
    <VExpansionPanel>
      <VExpansionPanelTitle>
        <slot name="title">{{ title }}</slot>
      </VExpansionPanelTitle>
      <VExpansionPanelText>
        <slot />
      </VExpansionPanelText>
    </VExpansionPanel>
  </VExpansionPanels>
</template>

<script lang="ts" setup>

import { VExpansionPanel, VExpansionPanelTitle, VExpansionPanelText, VExpansionPanels } from 'vuetify/components';

const props = defineProps<{
  title: string
}>()

</script>
