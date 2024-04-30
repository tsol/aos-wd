import { toast } from 'vuetify-sonner';

const ok = (message: string) => {

  toast(message, {
    duration: 3500,
    onAutoClose: () => {},
    onDismiss: () => {},
    
    id: 'my-toast',
    important: true,
    cardProps: {
      color: 'success',
      class: 'my-toast',
    },
    cardTextProps: {
      // v-card-text props
    },
    cardActionsProps: {
      // v-card-actions props
    },
    prependIcon: 'mdi-check-circle',
    prependIconProps: {
      // v-icon props
    },
  })

};

const error = (message: string) => {
  toast(message, {
    duration: 3500,
    onAutoClose: () => {},
    onDismiss: () => {},
    id: 'my-toast',
    important: true,
    cardProps: {
      color: 'error',
      class: 'my-toast',
    },
    cardTextProps: {
      // v-card-text props
    },
    cardActionsProps: {
      // v-card-actions props
    },
    prependIcon: 'mdi-alert-circle',
    prependIconProps: {
      // v-icon props
    }
  }
  );

};

export function useToast() {
  return { ok, error };
}
