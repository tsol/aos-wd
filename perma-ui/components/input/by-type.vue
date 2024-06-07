<template>
  <Component
    v-bind="$attrs"
    :is="input.component"
    v-model="value"
    :rules="[rules]"
  />
</template>

<script lang="ts" setup>
import { computed } from 'vue';
import { INPUTS_MAP } from './inputs.interface';

const props = defineProps<{
  type: keyof typeof INPUTS_MAP;
  modelValue: any;
  optional?: boolean;
}>();

const emit = defineEmits<{
  (event: 'update:modelValue', value: any): void,
  (event: 'update:safeValue', value: any): void,
  (event: 'valid', value: boolean): void,
}>();

if (!props.type) {
  throw new Error('Type is required');
}

const input = INPUTS_MAP[props.type as keyof typeof INPUTS_MAP];

if (!input) {
  throw new Error(`Type ${props.type} is not supported`);
}

const zod = props.optional ? input.zod.optional() : input.zod;

function convertOut(value: any) {
  const convFn = input.convertOut;
  if (! convFn) return value;
  return convFn(value);
}

// eslint-disable-next-line @typescript-eslint/no-unused-vars
function convertIn(value: any) {
  const convFn = input.convertIn;
  if (! convFn) return value;
  return convFn(value);
}

const value = computed({
  get: () => convertIn(props.modelValue),
  set: (value) => {
    emit('update:modelValue', value);

    const sv = convertOut(value);
    if (convertIn(sv) !== value)
      emit('update:safeValue', undefined);
    else
      emit('update:safeValue', sv);
  }
});

function rules(value: any) {

  if (props.optional && !value) { emit('valid', true); return true; }

  if (! props.optional && !value) {
    emit('valid', false);
    return 'Required';
  }
  
  const val = convertOut(value);
  const p = zod.safeParse(val);

  emit('valid', p.success);
  
  return p.success ? true : 
   ( input.formatErrorMsg || p.error.errors.map((e) => e.message).join(', ') );
  
}

</script>

