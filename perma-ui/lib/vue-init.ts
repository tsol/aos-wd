import { createApp  } from 'vue';
import { createVuetify } from 'vuetify';

import 'vuetify/dist/vuetify.css';
import 'vuetify/styles'

import {
  VAlert,
  VApp,
  VAutocomplete,
  VAvatar,
  VBadge,
  // VBreadcrumbs,
  // VBreadcrumbsItem,
  VBtn,
  VBtnToggle,
  VCard,
  VCardActions,
  VCardSubtitle,
  VCardText,
  VCardTitle,
  VCheckbox,
  VChip,
  VColorPicker,
  VCounter,
  VDataTable,
  VDatePicker,
  VDatePickerHeader,
  VDatePickerYears,
  VDialog,
  VDivider,
  VExpansionPanel,
  VExpansionPanels,
  VExpansionPanelText,
  VExpansionPanelTitle,
  VExpandTransition,

  // VFileInput,
  // VFooter,
  // VForm,
  VIcon,
  VImg,
  VInput,
  VItem,
  VItemGroup,
  VLabel,
  VList,
  VListGroup,
  VListItem,
  VListItemAction,
  VListItemSubtitle,
  VListItemTitle,
  VMenu,
  VMessages,
  VNavigationDrawer,
  VOverlay,
  VPagination,
  VProgressCircular,
  VProgressLinear,
  VRadio,
  VRadioGroup,
  VRangeSlider,
  VRating,
  VResponsive,
  VRow,
  VSelect,
  // VSkeletonLoader,
  VSlider,
  VSnackbar,
  VSpacer,
  VStepper,
  VStepperHeader,
  VSwitch,
  VSystemBar,
  VTabs,
  VTab,
  VTextField,
  VTextarea,
  VTimeline,
  VTimelineItem,
  VToolbar,
  VToolbarTitle,
  VTooltip,
  // VVirtualScroll,
} from 'vuetify/components';

import UiInput from '../components/ui-input.vue';
import UiButton from '../components/ui-button.vue';
import UiTimer from '../components/ui-timer.vue';
import UiExpPanel from '../components/ui-exp-panel.vue';
import type { useWallet } from '~/core/useWallet';

export interface InitVueParams {
  html: string;
  stateRef: Ref<any>;
  pageStateRef: Ref<any>;
  loadingRef: Ref<boolean>;
  aoSendMsg: (tags: Tag[]) => void;
  wallet?: ReturnType<typeof useWallet>;
}

export function initVue( params: InitVueParams ) {

  const html = `
  <v-app theme="dark">
  <div class="v-container">`
    +
     params.html
      .replace(/<ui-input/g, '<ui-input :state="state.ui" :inputs-validity="inputsValidity"')
      .replace(/<ui-button/g, '<ui-button :ui-loading="loading" :state="state.ui" :ao-send-msg="aoSendMsg" :inputs-validity="inputsValidity"')
      .replace(/<ui-timer/g, '<ui-timer :state="state.ui" :ao-send-msg="aoSendMsg"')
    + `
  </div>
  <div v-if="loading" class="text-center mt-4">
    <v-progress-circular indeterminate color="primary"></v-progress-circular>
  </div>
  </v-app>
  `;

  const vueApp = createApp({
    components: {
      UiInput,
      UiButton,
      UiTimer,
      UiExpPanel,

      VAlert,
      VApp,
      VAutocomplete,
      VAvatar,
      VBadge,
      // VBreadcrumbs,
      // VBreadcrumbsItem,
      VBtn,
      VBtnToggle,
      VCard,
      VCardActions,
      VCardSubtitle,
      VCardText,
      VCardTitle,
      VCheckbox,
      VChip,
      VColorPicker,
      VCounter,
      VDataTable,
      VDatePicker,
      VDatePickerHeader,
      VDatePickerYears,
      VDialog,
      VDivider,
      VExpansionPanel,
      VExpansionPanels,
  VExpansionPanelText,
  VExpansionPanelTitle,
  VExpandTransition,
  
      // VFileInput,
      // VFooter,
      // VForm,
      VIcon,
      VImg,
      VInput,
      VItem,
      VItemGroup,
      VLabel,
      VList,
      VListGroup,
      VListItem,
      VListItemAction,
      VListItemSubtitle,
      VListItemTitle,
      VMenu,
      VMessages,
      VNavigationDrawer,
      VOverlay,
      VPagination,
      VProgressCircular,
      VProgressLinear,
      VRadio,
      VRadioGroup,
      VRangeSlider,
      VRating,
      VResponsive,
      VRow,
      VSelect,
      // VSkeletonLoader,
      VSlider,
      VSnackbar,
      VSpacer,
      VStepper,
      VStepperHeader,
      VSwitch,
      VSystemBar,
      VTabs,
      VTab,
      VTextField,
      VTextarea,
      VTimeline,
      VTimelineItem,
      VToolbar,
      VToolbarTitle,
      VTooltip,
      // VVirtualScroll,
    },
    data() {
      return { 
        inputsValidity: {},
        state: params.stateRef,
        page: params.pageStateRef,
        loading: params.loadingRef,
        aoSendMsg: params.aoSendMsg,
        wallet: params.wallet,
      };
    },
    template: html,
  });

  const vuetify = createVuetify();
  vueApp.use(vuetify);
  return vueApp;
}

