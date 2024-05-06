<template>
  <div ref="appId"></div>
</template>

<script lang="ts" setup>
import { createApp, ref, watch } from 'vue';
import { createVuetify } from 'vuetify';
import 'vuetify/dist/vuetify.css';

// Import all Vuetify 3 components
import {
  VAlert,
  VApp,
  VAutocomplete,
  VAvatar,
  VBadge,
  VBreadcrumbs,
  VBreadcrumbsItem,
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
  VFileInput,
  VFooter,
  VForm,
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
  VSkeletonLoader,
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
  VVirtualScroll,
} from 'vuetify/components';

import UiInput from './ui-input.vue';
import UiButton from './ui-button.vue';

import cloneDeep from 'lodash.clonedeep';

const props = defineProps<{
  pid: string;
  html: string;
  state?: Record<string, any>;
  loading?: boolean;
 }>();

const process = useProcess<any>(props.pid);

const appId = ref();

let vueApp: any = undefined;

onMounted(() => {
  
  const noonce = Math.random().toString();

  const tags = [
    { name: "Action", value: "UIGetPage" }, 
    { name: "Path", value: "/" },
    { name: "Noonce", value: noonce },
  ];

  process.command('GET_PAGE', false, tags);
  process.setStateVariable('UI', '_noonce', noonce);

});

watch([() => props.html, () => props.state, appId], () => {

  if (!props.html || !props.state || !appId.value) {
    return;
  }

  if (vueApp) {
    vueApp.unmount();
  }

  const html =
     props.html.replace(/<ui-input/g, '<ui-input :state="state" :inputs-validity="inputsValidity"')
      .replace(/<ui-button/g, '<ui-button :ui-loading="loading" :state="state" :inputs-validity="inputsValidity" :process="process"');

  vueApp = createApp({
    components: {
      UiInput,
      UiButton,

      VAlert,
      VApp,
      VAutocomplete,
      VAvatar,
      VBadge,
      VBreadcrumbs,
      VBreadcrumbsItem,
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
      VFileInput,
      VFooter,
      VForm,
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
      VSkeletonLoader,
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
      VVirtualScroll,
    },
    data() {
      return { 
        state: cloneDeep(toRaw(props.state)),
        inputsValidity: {},
        process,
        loading: toRef(props, 'loading'),
      };
    },
    template: html,
  });

  const vuetify = createVuetify();
  vueApp.use(vuetify);

  vueApp.mount(appId.value);
}, { immediate: true, deep: true});

</script>
