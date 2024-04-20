<template>
  <div>
    <div v-if="props.variables.length === 0">No &#123;&#123;variables&#125;&#125; in template</div>
    <div v-else>
      <div v-for="variable in props.variables" :key="variable">
        <select-process v-if="variable.toLocaleLowerCase().endsWith('pid')" v-model="values[variable]" :label="variable" required />
        <v-text-field
          v-else
          v-model="values[variable]"
          :label="variable"
          required
          :rules="[v => !!v || 'Field is required']"
        >
        </v-text-field>
      </div>
      <v-btn @click="doSubmit">
        <template #prepend>
          <v-icon>mdi-content-save</v-icon>
        </template>
        SAVE
      </v-btn>
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
