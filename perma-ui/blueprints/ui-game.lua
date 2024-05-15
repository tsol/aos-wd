Houses = {
  House = "🏠",
  Garden = "🏡",
  Houses = "🏘️",
  Derelict = "🏚️",
  Construction = "🏗️",
  Office = "🏢",
  JapanesePostOffice = "🏣",
  PostOffice = "🏤",
  Hospital = "🏥",
  Bank = "🏦",
  Hotel = "🏨",
  LoveHotel = "🏩",
  ConvenienceStore = "🏪",
  School = "🏫",
  DepartmentStore = "🏬",
  Factory = "🏭",
  JapaneseCastle = "🏯",
  Castle = "🏰",

  Fountain = "⛲",
  StatueOfLiberty = "🗽",
  TokyoTower = "🗼",
  Stadium = "🏟️",
}

Icons = {
  WhiteMediumStar = "⭐",
  GlowingStar = "🌟",
  Sparkles = "✨",
  Cyclone = "🌀",
  Foggy = "🌁",
  Rainbow = "🌈",
  ClosedUmbrella = "🌂",
  HighVoltage = "⚡",
  Snowflake = "❄️",
  Fire = "🔥",
  Droplet = "💧",
  WindFace = "🌬️",
}

Nature = {
  Tree = "🌳",
  DeciduousTree = "🌲",
  PalmTree = "🌴",
  Cactus = "🌵",
  EvergreenTree = "🌿",
  Herb = "🌱",
  Shamrock = "☘️",
  FourLeafClover = "🍀",
  FallenLeaf = "🍂",
  LeafFlutteringWind = "🍃",
  SheafOfRice = "🌾",
  Hibiscus = "🌺",
  Sunflower = "🌻",
  Blossom = "🌼",
  Tulip = "🌷",
  Rose = "🌹",
}

Fruits = {
  Apple = '🍎',
  Banana = '🍌',
  Cherry = '🍒',
  Mango = '🥭',
  Watermelon = '🍉',
  Pineapple = '🍍',
  Strawberry = '🍓',
  Kiwi = '🥝',
  Grapes = '🍇',
  Orange = '🍊',
  Peach = '🍑',
  Pear = '🍐',
  Plum = '🍑',
  Lemon = '🍋',
  Lime = '🍈',
  Coconut = '🥥',
  Pomegranate = '🥭',
  Blueberry = '🫐',
  Raspberry = '🍇',
  Blackberry = '🫐',
  Cranberry = '🍒',
  Gooseberry = '🍇',
  Apricot = '🍑',
  Papaya = '🥭'
}


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
          title = "Castle",
          icon = Houses.Castle,
        },
        {
          title = "Fountain",
          icon = Houses.Fountain,
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
          <ui-button class="ml-2" ui-run="UI.page({ path = '{~prevPath~}' })">Go back</ui-button>
        ]]
    },

  },

  InitState = function(pid)
    return {
      name = "",
      fruit = ""
    }
  end,
}

DIRECTIONS = { n = { 0, -1, 0 }, s = { 0, 1, 0 }, e = { 1, 0, 0 }, w = { -1, 0, 0 } }
OPOSITES = { n = 's', s = 'n', e = 'w', w = 'e' }

function error(msg)
  UI.reply(UI.renderError(500, msg))
  return ''
end

function InitPageState()
  return {
    people = {}
  }
end


function roomLayoutNavigation(page)
  function btn(dir, title, empty)
    local variant = empty and 'outlined' or 'flat'
    local cmd = empty and 'cmdBuild' or 'cmdGo'
    local color = empty and 'grey' or '#4f545c'

    return string.format([[
      <v-tooltip text="%s">
        <template v-slot:activator="{ props }">
          <ui-button color="%s" variant="%s" v-bind="props" ui-run="%s({ dir = '%s' })">
          %s
          </ui-button>
        </template>
      </v-tooltip>
      ]], title, color, variant, cmd, dir, dir)
  end

  local navButtons = {
    n = btn('n', 'Nothing North', true),
    w = btn('w', 'Nothing West', true),
    e = btn('e', 'Nothing East', true),
    s = btn('s', 'Nothing South', true),
  }

  for dir, path in pairs(page.exits) do
    local title = UI.findPage(path).title
    navButtons[dir] = btn(dir, title)
  end

  return string.format([[
    <div style="max-width: 132px;">
      <v-row no-gutters class="mb-1">
        <div class="v-col-12 text-center">%s</div>
      </v-row>
      <v-row no-gutters>
        <div class="v-col-6">%s</div>
        <div class="v-col-6">%s</div>
      </v-row>
      <v-row no-gutters class="mt-1">
        <div class="v-col-12 text-center">%s</div>
      </v-row>
    </div>
  ]], navButtons.n or '-', navButtons.w or '-', navButtons.e or '-', navButtons.s or '-')
end

-- page = { "people": [ { "pid": "KjpdUofQA4FSBgMV7CsdcqV4CNZMz-AZayNHcirjEnY", "fruit": "Cherry", "name": "yaya" } ] }

function roomLayoutPeople(page)
  -- this is dynamic component. page here is page state recieved by vue
  -- also state - is the players state
  -- once someone enters the room - this will automatically update
  return [[
      <h3>People in the room</h3>
      <div v-for="person in (page.people || [])" :key="person.pid">
        {{ person.name }} is here holding {{ { Apple: '🍎', Banana: '🍌', Cherry: '🍒', Mango: '🥭', Watermelon: '🍉', Pineapple: '🍍', Strawberry: '🍓', Kiwi: '🥝', Grapes: '🍇', Orange: '🍊', Peach: '🍑', Pear: '🍐', Plum: '🍑', Lemon: '🍋', Lime: '🍈', Coconut: '🥥', Pomegranate: '🥭', Blueberry: '🫐', Raspberry: '🍇', Blackberry: '🫐', Cranberry: '🍒', Gooseberry: '🍇', Apricot: '🍑', Papaya: '🥭' }[person.fruit] || person.fruit }}
      </div>
    ]]
end

function roomLayoutEnvironment(page)
  if not page.environment then return '' end

  local res = ''

  for _, env in ipairs(page.environment) do
    res = res .. string.format([[
        <v-tooltip text="%s" location="bottom">
          <template v-slot:activator="{ props }">
            <span v-bind="props">%s</span>
          </template>
        </v-tooltip>
    ]], env.title, env.icon)
  end

  return res
end

function roomLayout(page)
  local res = '<h1>' .. page.title .. '</h1>'

  res = res .. page.html

  res = res .. roomLayoutEnvironment(page)

  res = res .. string.format([[
    <v-divider class="my-4"></v-divider>
    <v-row>
      <div class="v-col-md-4">
        %s
      </div>
      <div class="v-col-md-8">
        %s
      </div>
    </v-row>
  ]], roomLayoutNavigation(page), roomLayoutPeople(page))


  return res
end

function createRoom(parentPagePath, direction, title, description)
  -- calculate new coordinates
  local diff = DIRECTIONS[direction]
  if not diff then return error("Invalid direction") end

  -- check if parent exists and its exit is free
  local parent = UI.findPage(parentPagePath)
  if not parent then return error("Parent room not found") end

  local parentExit = parent.exits[direction]
  if parentExit then return error("Parent exit already exists") end

  -- parse parent coordinates
  local x, y, z = parentPagePath:match('(%d+)-(%d+)-(%d+)')
  x, y, z = tonumber(x), tonumber(y), tonumber(z)

  local nx, ny, nz = x + diff[1], y + diff[2], z + diff[3]
  local path = string.format('/%d-%d-%d', nx, ny, nz)

  -- check if exits
  local found = UI.findPage(path)
  if found then return error("Room already exists") end

  -- create new page
  local page = {
    path = path,
    layout = roomLayout,
    state = InitPageState(),
    title = title,
    html = description,
    exits = { [OPOSITES[direction]] = parentPagePath }
  }

  UI_APP.PAGES[#UI_APP.PAGES + 1] = page

  -- update parent exit
  parent.exits[direction] = path

  return path
end

-- DEFAULT MAZE GENERATION
createRoom('/1000-1000-1000', 'n', 'North Square', [[
  <p class="mb-4">
    You find yourself on the city north square.
    The sun is shining, the birds are singing, and the people are walking around.
  </p>
]])

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

--

function removePersonFromRoom(page, pid)
  if not page.state.people then return end
  local wasUpdate = false

  for i, person in ipairs(page.state.people) do
    if person.pid == pid then
      table.remove(page.state.people, i)
      wasUpdate = true
    end
  end

  if wasUpdate then
    UI.sendPageState(page)
  end

  return wasUpdate
end

function putPersonToRoom(page, pid)
  if not page.state.people then page.state.people = {} end
  local wasUpdate = false

  -- check that person already in room
  for _, person in ipairs(page.state.people) do
    if person.pid == pid then return false end
  end

  -- find state in UI_STATE[pid] - { name, fruit }
  local state = UI_STATE[pid]
  if not state then return error("No state for pid") end

  local person = { pid = pid, name = state.name, fruit = state.fruit }

  table.insert(page.state.people, person)

  UI.sendPageState(page)

  return true
end

function cmdBuild(args)
  local direction = args.dir

  UI.set({
    prevPath = UI.currentPath(),
    roomEditTitle = "",
    roomEditDescription = "",
    roomeEditDirection = direction
  })

  return UI.page({ path = '/build-room' })

end

function cmdConfirmBuild(args)

  local title = args.title
  local description = args.desc
  local parentPath = UI_STATE[UI.currentPid].prevPath
  local direction = UI_STATE[UI.currentPid].roomeEditDirection

  createRoom(parentPath, direction, title, description)

  UI_STATE[UI.currentPid].prevPath = nil
  UI_STATE[UI.currentPid].roomeEditDirection = nil
  UI_STATE[UI.currentPid].roomEditTitle = nil
  UI_STATE[UI.currentPid].path = parentPath

  return cmdGo({ dir = direction })

end


function cmdGo(args)
  local direction = args.dir

  local page = UI.findPage(UI.currentPath())
  if not page then return error("User room not found") end

  local exit = page.exits[direction]

  if not exit then return error("No exit in that direction") end

  local newPage = UI.findPage(exit)
  if not newPage then return error("Dst room not found") end

  local pid = UI.currentPid

  removePersonFromRoom(page, pid)
  putPersonToRoom(newPage, pid)

  return
      UI.page({ path = exit }) ..
      UI.pageState(newPage) ..
      UI.state()
end

function cmdLogin(args)
  UI.set({ name = args.name, fruit = args.fruit })
  local cityCenter = UI.findPage('/1000-1000-1000')

  putPersonToRoom(cityCenter, UI.currentPid)
  return
      UI.page({ path = "/1000-1000-1000" }) ..
      UI.pageState(cityCenter) ..
      UI.state()
end

function cmdLogout(args)
  UI.set({ name = "" })
  return UI.page({ path = "/" })
end
