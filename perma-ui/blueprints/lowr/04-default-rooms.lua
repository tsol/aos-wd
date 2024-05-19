-- DEFAULT MAZE GENERATION
createRoom('/1000-1000-1000', 'n', 'Forest', [[
  <p class="mb-4">
    You find yourself in a dark forest.
  </p>
]])

UI.findPage('/1000-999-1000').state.spawnMonstersLevel = 1


createRoom('/1000-999-1000', 'n', 'Forest 2', [[
  <p class="mb-4">
    As you go north, forest seems to become darker.
  </p>
]])

UI.findPage('/1000-998-1000').state.spawnMonstersLevel = 2


createRoom('/1000-998-1000', 'n', 'Forest 3', [[
  <p class="mb-4">
    It's dark here. You thinking about going back.
  </p>
]])

UI.findPage('/1000-997-1000').state.spawnMonstersLevel = 3


createRoom('/1000-997-1000', 'n', 'Forest 4', [[
  <p class="mb-4">
    Noises are getting louder. You're not alone here.
  </p>
]])

UI.findPage('/1000-996-1000').state.spawnMonstersLevel = 4


createRoom('/1000-996-1000', 'n', 'Forest 5', [[
  <p class="mb-4">
    You see a light in the distance.
  </p>
]])

UI.findPage('/1000-995-1000').state.spawnMonstersLevel = 5

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
