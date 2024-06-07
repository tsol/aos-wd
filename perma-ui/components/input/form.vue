<template>
  <div>
    <div
      v-for="field in props.fields"
      :key="field.name"
    >
      <input-by-type
        :type="field.input"
        :model-value="modelValues[field.name]"
        :label="field.label"
        :optional="!field.required"
        @update:model-value="(val: any) => modelValues[field.name] = val"
        @update:safe-value="(val: any) => safeValues[field.name] = val"
        @valid="(val: boolean) => fieldsValid[field.name] = val"
      />
    </div>
    <v-btn
      :disabled="!formValid"
      @click="onSubmit"
    >
      Submit
    </v-btn>
  </div>
</template>

<script lang="ts" setup>
import { computed, ref } from 'vue';
import type { FormField } from './form.interface';
import { INPUTS_MAP } from './inputs.interface';

const props = defineProps<{
  fields: FormField<keyof typeof INPUTS_MAP>[];
}>();

const emit = defineEmits<{
  (event: 'submit', value: { [key: string]: any }): void,
}>();

const fieldsValid = ref<{ [key: string]: boolean }>(props.fields.reduce((acc, field) => {
  acc[field.name] = !field.required;
  return acc;
}, {} as { [key: string]: boolean })
);

const formValid = computed(() => {
  const allValid = Object.values(fieldsValid.value).every((v) => v) || Object.keys(fieldsValid.value).length === 0;
  const requiredNotEmpty = props.fields.filter((f) => f.required).every((f) => !!safeValues.value[f.name]);
  return allValid && requiredNotEmpty;
});

const modelValues = ref<{ [key: string]: any }>(props.fields.reduce((acc, field) => {
  acc[field.name] = field.initialValue;
  return acc;
}, {} as { [key: string]: any })
);

const safeValues = ref<{ [key: string]: any }>(
  props.fields.reduce((acc, field) => {
    acc[field.name] = field.initialValue;
    return acc;
  }, {} as { [key: string]: any })
);

function onSubmit() {
  emit('submit', safeValues.value);
}

</script>
