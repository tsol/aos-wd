<template>
  <div :style="{ minWidth, maxWidth, flexShrink: 0 }">
    <span v-if="!editMode" @click="startEdit">
      {{ value }}
      <v-icon size="x-small" color="grey" class="ml-2">mdi-pencil-box-outline</v-icon>
    </span>

    <v-text-field
      v-else
      ref="inputRef"
      v-model="editValue"
      density="compact"
      variant="underlined"
      :hide-details="true"
      @keydown.enter="doSave"
      @keydown.esc.stop.prevent="editMode = false"
    >
      <template #append-inner>
        <v-icon color="error" size="small" @click="editMode = false">mdi-close</v-icon>
        <v-icon color="success" size="small" @click="doSave">mdi-check</v-icon>
      </template>
    </v-text-field>
  </div>
</template>

<script lang="ts" setup>
import { useDisplay } from 'vuetify';


const props = withDefaults(defineProps<{
  value: string;
  maxWidth?: number;
  maxWidthSmall?: number;
}>(), {
  maxWidth: 350,
  maxWidthSmall: 200
});

const emit = defineEmits<{
  (event: 'changed', value: string): void;
}>();

const { mdAndUp } = useDisplay();

const editMode = ref(false);
const alteredValue = ref(props.value || '');
const inputRef = ref<HTMLInputElement | null>(null);

const editValue = computed({
  get: () => props.value || '',
  set: (val: string) => {
    alteredValue.value = val;
  }
});

const minWidth = computed(() => {
  const maxW = mdAndUp.value ? props.maxWidth : props.maxWidthSmall;
  return `max(200px, min(${props.value.length + 4}ch, ${maxW}px))`;
});

const maxWidth = computed(() => {
  const maxW = mdAndUp.value ? props.maxWidth : props.maxWidthSmall;
  return `${maxW}px`;
});


function startEdit() {
  editMode.value = true;
  alteredValue.value = props.value;
  setTimeout(() => {
    inputRef.value?.focus();
  }, 100);
}

function doSave() {
  emit('changed', alteredValue.value);
  editMode.value = false;
}

</script>

<style></style>