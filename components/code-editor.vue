<template>
    <prism-editor
      ref="editor"
      class="my-editor"
      v-model="code"
      :highlight="highlighter"
      @click="clickHandler"
    ></prism-editor>
</template>

<script lang="ts" setup>
import 'vue-prism-editor/dist/prismeditor.min.css'; // import the styles somewhere
import { PrismEditor } from 'vue-prism-editor';
import { highlight, languages } from 'prismjs';

const props = defineProps<{
  modelValue: string;
}>();

const emit = defineEmits<{
  (event: 'update:modelValue', value: string): void,
  (event: 'onSelected', value: { start?: number, end?: number; text: string }): void,
  (event: 'onClicked', value: { start?: number, end?: number; }): void,
}>();

languages.lua = {
  'comment': /^#!.+|--(?:\[(=*)\[[\s\S]*?\]\1\]|.*)/m,
  'string': {
    pattern: /(["'])(?:(?!\1)[^\\\r\n]|\\z(?:\r\n|\s)|\\(?:\r\n|[^z]))*\1|\[(=*)\[[\s\S]*?\]\2\]/,
    greedy: true
  },
  'number': /\b0x[a-f\d]+(?:\.[a-f\d]*)?(?:p[+-]?\d+)?\b|\b\d+(?:\.\B|(?:\.\d*)?(?:e[+-]?\d+)?\b)|\B\.\d+(?:e[+-]?\d+)?\b/i,
  'keyword': /\b(?:and|break|do|else|elseif|end|false|for|function|goto|if|in|local|nil|not|or|repeat|return|then|true|until|while)\b/,
  'function': /(?!\d)\w+(?=\s*(?:[({]))/,
  'operator': [
    /[-+*%^&|#]|\/\/?|<[<=]?|>[>=]?|[=~]=?/,
    {
      // Match ".." but don't break "..."
      pattern: /(^|[^.])\.\.(?!\.)/,
      lookbehind: true
    }
  ],
  'punctuation': /[\[\](){},;]|\.+|:+/
};

// import 'prismjs/components/prism-clike';
// import 'prismjs/components/prism-javascript';
import 'prismjs/components/prism-lua';
import 'prismjs/themes/prism-tomorrow.css';

const editor = ref<HTMLDivElement | null>(null);
let textareaEl = ref<HTMLTextAreaElement | null>(null);

const code = ref(props.modelValue);
const selection = ref('');

watch(() => props.modelValue, (value) => {
  code.value = value;
});

watch(() => code.value, (value) => {
  emit('update:modelValue', value);
});


function highlighter(code: string) {
  return highlight(code, languages.js, 'lua'); //returns html
};

function clickHandler($event: any) {
  if (!textareaEl.value) return;
  const t = textareaEl.value;
  if (t.selectionStart === t.selectionEnd) {
    selection.value = '';
    emit('onSelected', { start: t.selectionStart, end: t.selectionEnd, text: '' });
  }
  emit('onClicked', { start: t.selectionStart, end: t.selectionEnd });
}

function selectHandler($event: any) {
  const t = textareaEl.value;
  if (!t) return;
  const selectedText = t.value.substring(t.selectionStart, t.selectionEnd);
  selection.value = selectedText;
  emit('onSelected', { start: t.selectionStart, end: t.selectionEnd, text: selectedText });
}


onMounted(() => {
  const textarea = (editor.value as any).$el.querySelector('textarea')
  if (!textarea) throw new Error('Textarea not found');
  textareaEl.value = textarea;
  textarea.addEventListener('select', selectHandler);
});

onUnmounted(() => {
  if (!textareaEl.value) return;
  textareaEl.value.removeEventListener('select', selectHandler);
});

</script>

<style global>

.my-editor {
  /* we dont use `language-` classes anymore so thats why we need to add background and text color manually */
  background: #2d2d2d;
  color: #ccc;

  /* you must provide font-family font-size line-height. Example: */
  font-family: Fira code, Fira Mono, Consolas, Menlo, Courier, monospace;
  font-size: 14px;
  line-height: 1.5;
  padding: 5px;

  height: 60vh;
  /* or 800px */
  overflow: auto;
}

.prism-editor__textarea:focus {
  outline: none;
}

</style>