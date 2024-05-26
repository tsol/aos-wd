--- UI_APP --------------------
UI_STATE = {}
UI.logs = {}

function InitPlayerState(pid)
  return {
    name = "",
    fruit = "",

    level = 1,
    charm = 1,
    exp = 0,

    maxHp = 15,
    hp = 15,
    gold = 100,

    str = 10,
    defence = 2,

    armor = ShopItemTypes.armor.none,
    weapon = ShopItemTypes.weapon.none,

    breadcrumbs = { forest = nil, hospital = '/hospital' }, -- per terrain last visited room

  }
end

function InitPageState(override)
  local default = {
    people = {},
    fight = false,
    roundStartTime = nil,
    spawnMonstersLevel = 0,
    maxMonsters = 3,
    messages = {}, -- array of strings { text = "Large mosquito attacked Player by 3 hp with their Sucker", t = 1234567890 }
    maxMessages = 20,
    terrain = nil,
  }

  if override then
    for k, v in pairs(override) do
      default[k] = v
    end
  end

  return default
end


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
          title = "Fountain",
          icon = Houses.Fountain,
          path = "/fountain",
        },
        {
          title = "Weapon Shop",
          icon = Medival.Dagger,
          path = "/weapon-shop",
        },
        {
          title = "Armor Shop",
          icon = Medival.Shield,
          path = "/armor-shop",
        },
      },
      html = [[        
          You find yourself on the city central square.
          The sun is shining, the birds are singing, and the people are walking around.
        ]],
      title = "Central Square",
      exits = {},
      state = InitPageState({ terrain = 'city' })
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
      exits = { n = '/1000-1000-1000' },
      state = InitPageState({
        terrain = 'hospital',
        noBreadcrumb = false,
        maxMonsters = 1,
      })
    },

    -- weapon shop
    {
      path = '/weapon-shop',
      layout = roomLayoutWeaponShop,
      environment = {},
      html = '',
      title = "Weapon Shop",
      exits = { n = '/1000-1000-1000' },
      state = InitPageState({
        terrain = 'weapons',
        noBreadcrumb = true,
        maxMonsters = 1,
      })
    },

    -- armor shop
    {
      path = '/armor-shop',
      layout = roomLayoutArmorShop,
      environment = {},
      html = [[

      ]],
      title = "Armor Shop",
      exits = { n = '/1000-1000-1000' },
      state = InitPageState({
        terrain = 'armor',
        noBreadcrumb = true,
        maxMonsters = 1,
      })
    },

    -- fountain
    {
      path = '/fountain',
      layout = roomLayoutFountain,
      environment = {},
      html = '',
      title = "Fountain",
      exits = { n = '/1000-1000-1000' },
      state = InitPageState({
        terrain = 'fountain',
        noBreadcrumb = true,
        maxMonsters = 1,
      })
    },

  },
  InitState = InitPlayerState

}

