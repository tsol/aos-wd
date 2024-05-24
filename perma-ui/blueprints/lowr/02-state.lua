--- UI_APP --------------------
UI_STATE = {}
UI.logs = {}

UI_APP = {

  PAGES = {
    {
      path = '/',
      guard = function(pid)
        if not UI_STATE[pid] or UI_STATE[pid].name == "" then
          return "/"
        end
        local room = UI_STATE[pid].path
        if not room then return "/1000-1000-1000" end
        return room
      end,
      html = [[
        <h1>The legend of the White Rabbit</h1>
        <p>Enter your name:</p>
        <ui-input ui-id="name" ui-type="String" ui-required label="Your name" />
        <ui-input
          ui-id="fruit"
          ui-type="Select"
          ui-required
          label="Your fruit"
          :items="['Apple', 'Banana', 'Cherry', 'Mango', 'Watermelon', 'Pineapple', 'Strawberry', 'Kiwi', 'Grapes', 'Orange', 'Peach', 'Pear', 'Plum', 'Lemon', 'Lime', 'Coconut', 'Pomegranate', 'Blueberry', 'Raspberry', 'Blackberry', 'Cranberry', 'Gooseberry', 'Apricot', 'Papaya']"
        />
        <ui-button ui-valid="name, fruit" ui-run="cmdLogin({ name = $name, fruit = $fruit })">Login</ui-button>
      ]]
    },
    {
      path = '/1000-1000-1000',
      layout = roomLayout,
      environment = {
        {
          title = "Hospital",
          icon = Houses.Hospital,
          path = "/hospital",
        },
        {
          title = "Tree",
          icon = Nature.Tree,
        },
      },
      html = [[
        <p class="mb-4">Welcome, {~name~}!</p>
        <p class="mb-4">
          You find yourself on the city central square.
          The sun is shining, the birds are singing, and the people are walking around.
        </p>
        ]],
      title = "Central Square",
      exits = {},
      state = InitPageState()
    },

    {
        path = '/build-room',
        html = [[
          <h1>Build new space</h1>

          <ui-input ui-id="roomEditTitle" ui-type="String" ui-required label="Location title" />
          <ui-input ui-id="roomEditDescription" ui-type="String" ui-required label="Location description" />

          <ui-button color="primary" ui-valid="roomEditTitle, roomEditDescription" ui-run="cmdConfirmBuild({ title = $roomEditTitle, desc = $roomEditDescription })">Build</ui-button>
          <ui-button class="ml-2" ui-run="cmdGo({ dir = '{~prevPath~}' })">Go back</ui-button>
        ]],
        title = "Build new space",
        exits = {},
        state = InitPageState()
    },

    -- hospital
    {
      path = '/hospital',
      layout = roomLayoutHospital,
      environment = {},
      html = '',
      title = "Hospital",
      exits = {},
      state = InitPageState()
    },

  },

  InitState = function(pid)
    return {
      name = "",
      fruit = "",
  
      level = 1,
      exp = 0,

      maxHp = 15,
      hp = 15,
      gold = 100,

      str = 10,
      defence = 2,

      armor = { name = "T-shirt", price = 0, defence = 0 },
      weapon = { name = "Fists", price = 0, str = 0 },

    }
  end,
}



