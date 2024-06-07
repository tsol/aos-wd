--- UI_APP --------------------
UI_STATE = UI_STATE or {}
UI.logs = {}

-- slow state with all additional details which are not needed for fast state and fast display
MEM = MEM or {}

function _RESET() -- dont do this in production
  UI_STATE = {}
  MEM = {}
  UI_APP = {
    PAGES = { UI_ROOT_PAGE },
    InitState = InitPlayerState
  }
end

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
    actTime = nil,
  }
end

function InitPageState(override)
  local default = {
    people = {},
    fight = false,
    roundStartTime = nil,
    spawnMonstersLevel = 0,
    maxMonstersStr = nil,
    maxMonsters = 3,
    messages = {},
    maxMessages = 20,
    terrain = nil,
    builtBy = nil,
  }

  if override then
    for k, v in pairs(override) do
      default[k] = v
    end
  end

  return default
end

function rootPageGuard(pid)
  if not UI_STATE[pid] or UI_STATE[pid].name == "" then
    return "/"
  end
  local room = UI_STATE[pid].path
  if not room then return "/1000-1000-1000" end
  return room
end

UI_ROOT_PAGE = {
  path = '/',
  guard = rootPageGuard,
  html = [[
    <h1 class="mb-6">The legend of the White Rabbit</h1>
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
}


-- Updating/Creating core pages

UI_APP.InitState = InitPlayerState

createStandaloneRoom(
  UI_ROOT_PAGE.path,
  UI_ROOT_PAGE.title,
  UI_ROOT_PAGE.html,
  InitPageState()
)

_page = UI.findPage(UI_ROOT_PAGE.path)
_page.guard = rootPageGuard

createStandaloneRoom(
  '/1000-1000-1000',
  'Central Square',
[[
  You find yourself on the city central square.
  The sun is shining, the birds are singing, and the people are walking around.
  Gates at the North are leading to the wilderness. Don't go there unless you are
  looking for trouble.
]],
  InitPageState({
    terrain = 'city',
    breadcrumb = true
  })
)

createStandaloneRoom(
  '/build-room',
  'Build new space',
[[
  <h1>Build new space</h1>

  <ui-input ui-id="roomEditTitle" ui-type="String" ui-required label="Location title" />
  <ui-input ui-id="roomEditDescription" ui-type="String" ui-required label="Location description" />

  <ui-button color="primary" ui-valid="roomEditTitle, roomEditDescription" ui-run="cmdConfirmBuild({ title = $roomEditTitle, desc = $roomEditDescription })">Build</ui-button>
  <ui-button class="ml-2" ui-run="cmdGo({ dir = '{~prevPath~}' })">Go back</ui-button>
]],
  InitPageState()
)
