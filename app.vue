<template>
  <v-app>
    <v-app-bar app>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer" />
      <Wallet />
      <Process />
    </v-app-bar>

    <v-navigation-drawer
      v-model="drawer"
      :temporary="false"
    >
      <v-list>
        <v-list-item
          title="Menu item"
        />
      </v-list>
    </v-navigation-drawer>
    <v-main>
      <v-container>
        <Console />
      </v-container>
    </v-main>
  </v-app>
</template>

<script lang="ts" setup>

const drawer = ref(false);

</script>