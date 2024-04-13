<template>
  <div>
    <v-text-field
      v-for="variable in props.variables"
      :key="variable"
      v-model="values[variable]"
      :label="variable"
      outlined
    ></v-text-field>
    <v-btn @click="doSubmit">Submit</v-btn>
  </div>
</template>

<script lang="ts" setup>

const props = defineProps<{
  pid: string;
  variables: string[];
}>();

const process = useProcess<any>(props.pid);
const values = ref<{ [key: string]: string }>({});

function doSubmit() {
  Object.entries(values.value).forEach(([key, value]) => {
    process.state.value[key] = value;
  });
}

</script>
