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

export interface InitVueParams {
  html: string;
  stateRef: Ref<any>;
  loadingRef: Ref<boolean>;
  aoSendMsg: (tags: Tag[]) => void;
}

export function initVue( params: InitVueParams ) {

  const html = `
  <v-app theme="dark">
  <v-main class="v-container">`
    +
     params.html.replace(/<ui-input/g, '<ui-input :state="state" :inputs-validity="inputsValidity"')
      .replace(/<ui-button/g, '<ui-button :ui-loading="loading" :state="state" :ao-send-msg="aoSendMsg" :inputs-validity="inputsValidity"')
    + `
  </v-main>
  <div v-if="loading" class="text-center mt-4">
    <v-progress-circular indeterminate color="primary"></v-progress-circular>
  </div>
  </v-app>
  `;


  
  const vueApp = createApp({
    components: {
      UiInput,
      UiButton,

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
        loading: params.loadingRef,
        aoSendMsg: params.aoSendMsg,
      };
    },
    template: html,
  });

  const vuetify = createVuetify();
  vueApp.use(vuetify);
  return vueApp;
}

