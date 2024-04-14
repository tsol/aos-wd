<template>
  <v-container>

      <h1 class="headline">AOS Widget Desktop (AOS-WD v39.0.0*)</h1>
      <h3 class="mb-6 text-gray">* almost the best lubricant for your AOS dev</h3>

      <p>With this tool for example you can setup your own Arena and several bots in a few clicks,
      and then start advancing your bots or your game with a help of a built-in IDE.
      Create fast to execute snippets, load blueprints, update Handlers by selecting only
      the portion of code you want to update, and much more.</p>

      <p class="highlight">
        Also you can develop your own widgets to make User Interface for any game
        or service you come up with.
      </p>
      
      <h2 class="mt-2">Features</h2>
      <ul class="styled-list">
        <li>Work with several AOS processes simultaneously</li>
        <li>Create and run processes with a single click</li>
        <li>Built-in IDE with syntax highlighting and execution / partial execution</li>
        <li>Built-in console with syntax highlighting</li>
        <li>Expandable with custom widgets</li>
        <li>Load blueprints right from aos or this project github in IDE</li>
      </ul>

      <h2 class="mt-2">Available Widgets</h2>
      <ul class="styled-list">
        <li>BotGame (in progress) - graphical GRID Arena BOT client. A good starting point for your bot development.</li>
        <li>Arena (in progress) - contains snippet for demo arena</li>
        <li>Console - console for the current process</li>
        <li>IDE - code editor with syntax highlighting</li>
      </ul>

  </v-container>
</template>

<script lang="ts" setup>
// Add your script here
</script>

<style scoped>
.styled-list {
  list-style-type: disc;
  padding-left: 20px;
}

.highlight {
  background-color: #ffff99;
  padding: 2em;
  margin-top: 1em;
}

</style>