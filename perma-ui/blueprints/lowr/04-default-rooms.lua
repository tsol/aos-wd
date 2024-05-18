-- DEFAULT MAZE GENERATION
createRoom('/1000-1000-1000', 'n', 'Forest', [[
  <p class="mb-4">
    You find yourself in a dark forest.
  </p>
]])

UI.findPage('/1000-999-1000').state.spawnMonstersLevel = 1

createRoom('/1000-1000-1000', 's', 'South Square', [[
  <p class="mb-4">
    You find yourself on the city south square.
    The sun is shining, the birds are singing, and the people are walking around.
  </p>
]])

createRoom('/1000-1000-1000', 'e', 'East Square', [[
  <p class="mb-4">
    You find yourself on the city east square.
    The sun is shining, the birds are singing, and the people are walking around.
  </p>
]])

createRoom('/1000-1000-1000', 'w', 'West Square', [[
  <p class="mb-4">
    You find yourself on the city west square.
    The sun is shining, the birds are singing, and the people are walking around.
  </p>
]])
