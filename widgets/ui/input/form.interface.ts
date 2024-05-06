import type { INPUTS_MAP } from "./inputs.interface";

export type FormField<I extends keyof typeof INPUTS_MAP> = {
  name: string;
  input: I,
  label?: string;
  required?: boolean;
  disabled?: boolean;
  hidden?: boolean;
  initialValue?: Zod.infer<typeof INPUTS_MAP[I]['zod']>;
  col?: number;
}

