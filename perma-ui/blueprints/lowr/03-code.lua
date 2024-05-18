DIRECTIONS = { n = { 0, -1, 0 }, s = { 0, 1, 0 }, e = { 1, 0, 0 }, w = { -1, 0, 0 } }
OPOSITES = { n = 's', s = 'n', e = 'w', w = 'e' }

Monsters = Monsters or {
  { level = 1, name = "Large Mosquito", str = 2, exp = 2, hp = 3, gold = 46, weapon = "Blood Sucker" },
}

function error(msg)
  UI.reply(UI.renderError(500, msg))
  return ''
end

function InitPageState()
  return {
    people = {},
    fight = false,
    spawnMonstersLevel = 0,
    messages = {}, -- array of strings { text = "Large mosquito attacked Player by 3 hp with his Sucker", t = 1234567890 }
    maxMessages = 20,
  }
end

function addRoomMessage(page, text)
  if not page.state.messages then page.state.messages = {} end

  -- table.insert(page.state.messages, { text = text, t = UI.now })

  -- if #page.state.messages > page.state.maxMessages then
  --   table.remove(page.state.messages, 1)
  -- end

  -- insert at the top and remove from bottom

  table.insert(page.state.messages, 1, { text = text, t = UI.now })

  if #page.state.messages > page.state.maxMessages then
    table.remove(page.state.messages)
  end


  UI.sendPageState(page)
end

function spawnMonster(level, roomPage)
  local pid = 'mob-' .. math.random(1000, 9999)

  local monstersOfLevel = {}
  for _, monster in ipairs(Monsters) do
    if monster.level == level then
      table.insert(monstersOfLevel, monster)
    end
  end

  local monster = monstersOfLevel[math.random(1, #monstersOfLevel)]

  UI.set({
    pid = pid,

    name = monster.name,
    fruit = monster.weapon,
    path = roomPage.path,

    isMonster = true,

    level = level,
    maxHp = monster.hp,

    armor = { name = 'Nothing', price = 0, defence = 0 },
    weapon = { name = monster.weapon, price = 0, str = monster.str },

    str = 0,
    defence = 0,

    hp = monster.hp,
    exp = monster.exp,
    gold = monster.gold,
  }, pid)


  putPersonToRoom(roomPage, pid)

  -- it's aggresive monster. right away attacks
  roundActionAttack(pid, UI.currentPid)
end

function killPerson(pid, killedByPid)
  local page = UI.findPage(UI_STATE[pid].path)

  if page then
    removePersonFromRoom(page, pid)

    if killedByPid then
      addRoomMessage(page, string.format("%s was killed by %s", UI_STATE[pid].name, UI_STATE[killedByPid].name))
    end
  end

  local wasMonster = UI_STATE[pid].isMonster

  if killedByPid then
    local expGain = wasMonster and UI_STATE[pid].exp or 0

    UI.set({
      gold = (UI_STATE[killedByPid].gold or 0) + (UI_STATE[pid].gold or 0),
      exp = (UI_STATE[killedByPid].exp or 0) + expGain,
    }, killedByPid)
  end

  if wasMonster then
    -- completely remove from state
    UI_STATE[pid] = nil
  else
    -- move player to central square (TODO: hospital)

    UI.set({ hp = 1, gold = 0 }, pid)

    local cityCenter = UI.findPage('/1000-1000-1000')
    putPersonToRoom(cityCenter, pid)
  end
end

function isRoomInFight(page)
  -- start fight if someone has targetPid
  -- if targetPid is not in the room - set targetPid to nil
  -- if no one fighting anymore - stop fight

  local fight = false

  for _, personInRoom in ipairs(page.state.people) do

    local me = personInRoom.self
    local target = personInRoom.roundCommandTarget

    if target then

      local targetInRoom = findPersonInRoom(page, target.pid)

      if not targetInRoom then
        personInRoom.roundCommandTarget = nil
        personInRoom.roundCommand = nil

        addRoomMessage(page, string.format("%s ran away from %s", target.name, me.name))
      else
        fight = true
      end
    end
  end

  return fight
end

function performAttacks(page)
  local shuffledPeople = {}

  for _, personInRoom in ipairs(page.state.people) do
    table.insert(shuffledPeople, personInRoom)
  end

  -- do shuffling
  for i = #shuffledPeople, 2, -1 do
    local j = math.random(i)
    shuffledPeople[i], shuffledPeople[j] = shuffledPeople[j], shuffledPeople[i]
  end

  for i = 1, #shuffledPeople do
    local personInRoom = shuffledPeople[i]

    if personInRoom.roundCommand == 'attack' then
      attack(personInRoom.pid, personInRoom.roundCommandTarget)
    end

    if personInRoom.roundCommand == 'run' then
      local direction = personInRoom.roundCommandDirection
      if direction then
        personGo(direction, personInRoom.pid)
      end

      -- local page = UI.findPage(UI_STATE[personInRoom.pid].path)
      -- if page then
      --   removePersonFromRoom(page, personInRoom.pid, direction)
      --   putPersonToRoom(page, personInRoom.pid, direction)
      -- end
    end
  end
end

function haveAllPeopleSubmittedRoundActions(page)
  for _, personInRoom in ipairs(page.state.people) do
    if not personInRoom.roundCommand then return false end
  end
  return true
end

function setMonstersRoundCommand(page)
  for _, personInRoom in ipairs(page.state.people) do
    if personInRoom.isMonster then
      if personInRoom.roundCommandTarget then
        personInRoom.roundCommand = 'attack'
      end
    end
  end
end

function roomUpdateState(page)
  -- perform attacks (TODO: later sort by speed)
  -- for now perform random shuffle

  setMonstersRoundCommand(page)

  local fight = isRoomInFight(page)

  if fight and haveAllPeopleSubmittedRoundActions(page) then
    performAttacks(page)
  end

  fight = isRoomInFight(page)

  if not page.state.fight and fight then
    addRoomMessage(page, "Fight started")
    page.state.fight = fight
  end

  if page.state.fight and not fight then
    addRoomMessage(page, "Fight ended")
    page.state.fight = fight
    return
  end

  UI.sendPageState(page)
end

function attack(attackerPid, targetPid)
  local attacker = UI_STATE[attackerPid]
  local target = UI_STATE[targetPid]

  if not attacker or not target then
    UI.log("attack", "Invalid pids: " .. attackerPid .. "/" .. targetPid)
    return ''
  end

  -- local damage = attacker.str + attacker.weapon.str - target.armor.defence - target.defence
  -- damage = math.max(0, damage - math.random(0, math.floor(damage * 0.2)))
  local halfAttackerStr = (attacker.str + attacker.weapon.str) / 2
  local targetDefence = target.armor.defence + target.defence

  local damage = math.max(0, math.floor(halfAttackerStr) + math.random(halfAttackerStr) - targetDefence)

  local page = UI.findPage(attacker.path)
  if page then
    if damage > 0 then
      addRoomMessage(page,
        string.format("%s attacked %s by %d hp with his %s", attacker.name, target.name, damage, attacker.weapon.name))
    else
      addRoomMessage(page, string.format("%s missed %s", attacker.name, target.name))
      return ''
    end
  end

  UI.set({ hp = target.hp - damage }, targetPid)

  if target.hp <= 0 then
    killPerson(targetPid, attackerPid)
    return ''
  end

  -- if player is a monster - attack back
  if target.isMonster then
    roundActionAttack(targetPid, attackerPid)
  end

  return ''
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
  if page.state.fight then
    return [[
      <div v-for="person in (page.people || [])" :key="person.pid" class="d-flex">
        <div>
          <ui-button v-if="person.pid !== ']] ..
    UI.currentPid ..
    [['" class="mr-2" variant="outlined" ui-run="cmdAttack" :ui-args="{ target: person.pid }">⚔️</ui-button>
        </div>
        <div v-if="person.roundCommandTarget">{{ person.name }} is here fighting {{ person.roundCommandTargetName }}</div>
        <div v-else>{{ person.name }} is here staring at the fight</div>
      </div>
      <div class="mt-4">
        Your current fight descision: {{ (page.people.find(p => p.pid === ']] ..
    UI.currentPid .. [[') || {})?.roundCommand || '-' }}
      </div>
    ]]
  end

  return [[
      <div v-for="person in (page.people || [])" :key="person.pid">
        {{ person.name }} is here with a {{ { Apple: '🍎', Banana: '🍌', Cherry: '🍒', Mango: '🥭', Watermelon: '🍉', Pineapple: '🍍', Strawberry: '🍓', Kiwi: '🥝', Grapes: '🍇', Orange: '🍊', Peach: '🍑', Pear: '🍐', Plum: '🍑', Lemon: '🍋', Lime: '🍈', Coconut: '🥥', Pomegranate: '🥭', Blueberry: '🫐', Raspberry: '🍇', Blackberry: '🫐', Cranberry: '🍒', Gooseberry: '🍇', Apricot: '🍑', Papaya: '🥭' }[person.fruit] || person.fruit }}
      </div>
    ]]
end

function roomLayoutMessages(page)
  return string.format([[
      <div
        v-for="message in (page.messages || [])"
        :key="message.t"
        :style="{ opacity: Math.max(0.1, 1 - (Number(%s) - Number(message.t)) / 1000000) }"
      >
        {{ message.text }}
      </div>
    ]], UI.now)
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
    <v-divider class="my-4"></v-divider>
    %s
  ]],
    roomLayoutNavigation(page),
    roomLayoutPeople(page),
    roomLayoutMessages(page)
  )

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

--

function removePersonFromRoom(page, pid, toDirection)
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

  pageOnPersonLeave(page, pid, toDirection)

  return wasUpdate
end

function putPersonToRoom(page, pid, fromDirection)
  if not page.state.people then page.state.people = {} end

  -- check that person already in room
  for _, person in ipairs(page.state.people) do
    if person.pid == pid then return false end
  end

  -- find state in UI_STATE[pid] - { name, fruit }
  local state = UI_STATE[pid]
  if not state then return error("No state for pid") end

  local person = { pid = pid, name = state.name, fruit = state.fruit }

  table.insert(page.state.people, person)

  pageOnPersonEnter(page, pid, fromDirection)

  UI.sendPageState(page)

  return true
end

function clearRoundCommands(page, pid)
  local peopleEntry = findPersonInRoom(page, pid)
  if not peopleEntry then return error("User not found in room") end

  peopleEntry.roundCommand = nil
  peopleEntry.roundCommandDirection = nil
  peopleEntry.roundCommandTarget = nil
end

function personGo(direction, pid)
  local page = UI.findPage(UI_STATE[pid].path)
  if not page then return error("Person room not found") end

  clearRoundCommands(page, pid)

  local exit = page.exits[direction]

  if not exit then return error("No exit in that direction") end

  local newPage = UI.findPage(exit)
  if not newPage then return error("Dst room not found") end

  if page.state.fight then
    roundActionRun(pid, direction)
    return exit
  end

  removePersonFromRoom(page, pid, direction)
  putPersonToRoom(newPage, pid, OPOSITES[direction])

  -- update room state
  roomUpdateState(page)
  roomUpdateState(newPage)

  return exit
end

function pageOnPersonEnter(page, pid, fromDirection)
  if UI_STATE[pid].isMonster then


  else
    -- HERE WE CAN ADD SOME EVENTS
    -- At first if there is no monsters in the room - we can spawn some

    if not page.state.fight then
      local level = page.state.spawnMonstersLevel
      if level > 0 then
        spawnMonster(level, page)
      end
    end
  end

  -- roomUpdateState(page)
end

function pageOnPersonLeave(page, pid, toDirection)
  if UI_STATE[pid].isMonster then

  else

  end

  -- roomUpdateState(page)
end

function findPersonInRoom(page, pid)
  if not page.state.people then return nil end

  for _, person in ipairs(page.state.people) do
    if person.pid == pid then return person end
  end

  return nil
end

function roundActionAttack(attackerPid, targetPid)
  if not attackerPid or not targetPid then return error("Invalid pids") end

  local page = UI.findPage(UI_STATE[attackerPid].path)
  if not page then return error("User room not found") end

  -- find in people array by pid
  local peopleEntry = findPersonInRoom(page, attackerPid)
  if not peopleEntry then return error("Target not found in room") end

  peopleEntry.roundCommandTarget = targetPid
  peopleEntry.roundCommandTargetName = UI_STATE[targetPid].name
  peopleEntry.roundCommand = 'attack'
  peopleEntry.roundCommandDirection = nil
end

function roundActionRun(pid, direction)
  local page = UI.findPage(UI_STATE[pid].path)
  if not page then return error("User room not found") end

  local peopleEntry = findPersonInRoom(page, pid)
  if not peopleEntry then return error("User not found in room") end

  peopleEntry.roundCommand = 'run'
  peopleEntry.roundCommandDirection = direction
  peopleEntry.roundCommandTarget = nil
  peopleEntry.roundCommandTargetName = nil
end

-- FROM HTML COMMANDS ---

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

function cmdAttack(args)
  local targetPid = args.target

  if not targetPid then return error("No target") end

  roundActionAttack(UI.currentPid, targetPid)

  local page = UI.findPage(UI_STATE[UI.currentPid].path)

  roomUpdateState(page)
  return UI.pageState(page) .. UI.state() .. UI.page({ path = UI.currentPath() })
end

function cmdGo(args)
  local direction = args.dir

  local exit = personGo(direction, UI.currentPid)
  local newPage = UI.findPage(exit)

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
