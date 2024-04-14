<template>
  <div>
    <div v-if="props.variables.length === 0">No &#123;&#123;variables&#125;&#125; in template</div>
    <div v-else>
    <v-text-field
      v-for="variable in props.variables"
      :key="variable"
      v-model="values[variable]"
      :label="variable"
      outlined
      density="compact"
      required
      :rules="[v => !!v || 'Field is required']"
    ></v-text-field>
    <v-btn @click="doSubmit">Apply</v-btn>
  </div>
  </div>
</template>

<script lang="ts" setup>

const props = defineProps<{
  pid: string;
  variables: string[];
}>();

const process = useProcess<any>(props.pid);
const values = ref<{ [key: string]: string }>({});

// watch(() => process.state.value, (value) => {
//   Object.entries(value).forEach(([key, value]) => {
//     (values.value[key] as any) = value;
//   });
// }, { immediate: true, deep: true });

onMounted(() => {
  props.variables.forEach((variable) => {
    values.value[variable] = process.state.value[variable] || '';
  });
});

function doSubmit() {
  Object.entries(values.value).forEach(([key, value]) => {
    process.state.value[key] = value;
  });
}

</script>
