import { VCheckbox, VSelect, VTextField } from "vuetify/components";

import z from 'zod';

export const INPUTS_MAP = {
  'ID': {
    component: VTextField,
    zod: z.string(),
    convertOut: undefined,
    convertIn: undefined,
    formatErrorMsg: undefined,
  },
  'String': {
    component: VTextField,
    zod: z.string(),
    convertOut: undefined,
    convertIn: undefined,
    formatErrorMsg: undefined,
  },
  'Boolean': {
    component: VCheckbox,
    zod: z.boolean(),
    convertOut: undefined,
    convertIn: undefined,
    formatErrorMsg: undefined,
  },
  'Int': {
    component: VTextField,
    zod: z.number(),
    convertOut: (value?: string) => parseInt(value || '0', 10),
    convertIn: (value?: number) => value?.toString(),
    formatErrorMsg: 'Expected a number',
  },
  'Float': {
    component: VTextField,
    zod: z.number(),
    convertOut: (value?: string) => parseFloat(value || '0'),
    convertIn: (value?: number) => value?.toString(),
    formatErrorMsg: 'Expected a float number',
  },
  'DateTime': {
    component: VTextField,
    zod: z.date(),
    convertOut: undefined,
    convertIn: undefined,
    formatErrorMsg: undefined,
  },
  'FilterValue': {
    component: VTextField,
    zod: z.any(),
    convertOut: undefined,
    convertIn: undefined,
    formatErrorMsg: undefined,
  },
  'Select': {
    component: VSelect,
    zod: z.any(),
    convertOut: undefined,
    convertIn: undefined,
    formatErrorMsg: undefined,
  },
}


