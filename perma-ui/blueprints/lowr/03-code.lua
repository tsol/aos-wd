DIRECTIONS = { n = { 0, -1, 0 }, s = { 0, 1, 0 }, e = { 1, 0, 0 }, w = { -1, 0, 0 } }
OPOSITES = { n = 's', s = 'n', e = 'w', w = 'e' }
ROUND_TIMEOUT = 30 -- seconds

Monsters = Monsters or {
  { level = 1, name = "Large Mosquito", str = 2, exp = 2, hp = 3, gold = 46, weapon = "Blood Sucker" },
}

--[[
  FlirtSchema = {
  { charm = 1, name = 'Wink', success = '%s winks at %s and %s blushes.', fail = '%s winks at %s and %s looks away.' },
  { charm = 2, name = 'Smile', success = '%s smiles at %s and %s smiles back.', fail = '%s smiles at %s and %s looks away.' },
  { charm = 3, name = 'Blow Kiss', success = '%s blows a kiss at %s and %s catches it.', fail = '%s blows a kiss at %s and %s dodges it.' },
  { charm = 4, name = 'Flirt', success = '%s flirts with %s and %s flirts back.', fail = '%s flirts with %s and %s looks away.' },
  { charm = 5, name = 'Hug', success = '%s hugs %s and %s hugs back.', fail = '%s hugs %s and %s pushes away.' },
  { charm = 6, name = 'Kiss', success = '%s kisses %s and %s kisses back.', fail = '%s kisses %s and %s slaps.' },
  { charm = 7, name = 'Make Out', success = '%s makes out with %s and %s makes out back.', fail = '%s makes out with %s and %s slaps.' },
  { charm = 8, name = 'Proposal', success = '%s proposes to %s and %s accepts.', fail = '%s proposes to %s and %s rejects.' },
  { charm = 9, name = 'Marriage', success = '%s marries %s and %s marries back.', fail = '%s marries %s and %s leaves.' },
  { charm = 10, name = 'Divorce', success = '%s divorces %s and %s divorces back.', fail = '%s divorces %s and %s leaves.' },
}


Monsters = {
  { level = "Hospital", type = "good", gender="she", unique = 1, name = "Lilly the nurse", str = 8, exp = 10, hp = 12, gold = 34, weapon = "Stethoscope" },
  { level = "Inn", type = "good", gender="she", unique = 1, name = "Sara the Barmaid", str = 6, exp = 8, hp = 10, gold = 23, weapon = "Beer Mug" },
  { level = "Fountain", type = "good", gender = "he", unique = 1, name = "Seth the Bard", str = 12, exp = 9, hp = 11, gold = 27, weapon = "Lute" },
]]
--

function error(msg)
  UI.reply(UI.renderError(500, msg))
  return ''
end

function addRoomMessage(page, text)
  if not page.state.messages then page.state.messages = {} end

  table.insert(page.state.messages, 1, { text = text, t = UI.now })

  if #page.state.messages > page.state.maxMessages then
    table.remove(page.state.messages)
  end

  -- UI.sendPageState(page)
end

function spawnMonster(level, roomPage, forceMonster)
  
  local pid = forceMonster and forceMonster.pid or 'mob-' .. math.random(1000, 9999)
  
  local monstersOfLevel = {}
  local monster = forceMonster or nil

  if not monster then
    for _, m in ipairs(Monsters) do
      if m.level == level then
        table.insert(monstersOfLevel, m)
      end
    end
    if #monstersOfLevel > 0 then
      monster = monstersOfLevel[math.random(1, #monstersOfLevel)]
    end
  end

  -- check if exists in STATE
  if UI_STATE[pid] then
    return ''
  end

  UI.set({
    name = monster.name,
    fruit = monster.weapon,

    isMonster = true,
    type = monster.type,

    level = level,
    maxHp = monster.hp,

    armor = monster.armor or { name = 'Nothing', price = 0, defence = 0 },
    weapon = { name = monster.weapon, price = 0, str = monster.str },

    str = 0,
    defence = 0,

    hp = monster.hp,
    exp = monster.exp,
    gold = monster.gold,
  }, pid)

  UI_STATE[pid].pid = pid

  putPersonToRoom(roomPage, pid)

  if isMonsterAgressive(UI_STATE[pid]) then
    roundActionAttack(pid, UI.currentPid)
  end

end

function getExpInfo(exp)
  local currentLevel = 1
  local currentMaster = Bosses[1]
  local nextMaster = Bosses[1]
  local needExp = 0

  -- using boss table
  for index, boss in ipairs(Bosses) do
    if exp >= boss.exp then
      currentLevel = index + 1
      currentMaster = boss
    else
      nextMaster = boss
      needExp = boss.exp - exp
      break
    end
  end

  return {
    level = currentLevel,
    currentMaster = currentMaster,
    nextMaster = nextMaster,
    needExp = needExp,
  }
end

function checkLevelUp(pid)
  local player = UI_STATE[pid]

  local expInfo = getExpInfo(player.exp)

  if expInfo.level > player.level then
    local newMaxHp = math.floor((player.maxHp + expInfo.currentMaster.hp) / 2)
    local newStr = math.floor((player.str + expInfo.currentMaster.str) / 2)

    UI.set({
      level = expInfo.level,
      maxHp = newMaxHp,
      hp = newMaxHp,
      str = newStr,
      defence = player.defence + 1,
    }, pid)

    addRoomMessage(UI.findPage(player.room), string.format("✨🌀 %s leveled up to %d 🌀✨", player.name, player.level))
  end
end

function killPerson(pid, killedByPid)
  local wasMonster = UI_STATE[pid].isMonster
  local expGain = wasMonster and UI_STATE[pid].exp or 25
  local goldGain = math.floor(UI_STATE[pid].gold * 0.9)

  if killedByPid then
    UI.set({
      gold = (UI_STATE[killedByPid].gold or 0) + goldGain,
      exp = (UI_STATE[killedByPid].exp or 0) + expGain,
    }, killedByPid)
    checkLevelUp(killedByPid)
  end

  local page = UI.findPage(UI_STATE[pid].room)

  if page then
    if killedByPid then
      addRoomMessage(page,
        string.format("%s was killed by %s who gained %d exp and %d 🪙",
          UI_STATE[pid].name,
          UI_STATE[killedByPid].name,
          expGain,
          goldGain
        ))
    end

    removePersonFromRoom(page, pid)
  end

  if wasMonster then
    -- completely remove from state
    UI_STATE[pid] = nil
  else
    UI.set({
      hp = 0,
      gold = UI_STATE[pid].gold - goldGain,
    }, pid)
  end
end

function isRoomInFight(page)
  -- start fight if someone has targetPid
  -- if targetPid is not in the room - set targetPid to nil
  -- if no one fighting anymore - stop fight

  local fight = false

  for _, personInRoom in ipairs(page.state.people) do
    if personInRoom.action == 'attack' or personInRoom.actionTargetPid then
      local targetInRoom = findPersonInRoom(page, personInRoom.actionTargetPid)
      if not targetInRoom then
        personInRoom.actionTargetPid = nil
        personInRoom.action = nil
      else
        fight = true
      end
    end
  end

  return fight
end

function performRoomActions(page)
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
    local personInRoom = findPersonInRoom(page, shuffledPeople[i].pid)

    if (personInRoom) then
      if (personInRoom.hp > 0) then
        if personInRoom.action == 'attack' then
          attack(personInRoom.pid, personInRoom.actionTargetPid)
        end

        if personInRoom.action == 'run' then
          local direction = personInRoom.actionDirection
          if direction then
            local newPath = personGo(direction, personInRoom.pid)

            if not personInRoom.isMonster and UI.currentPid ~= personInRoom.pid then
              UI.forceSendPageToPid(personInRoom.pid, newPath)
            end
          end
        end
      end

      if not personInRoom.isMonster then
        personInRoom.action = nil
      end
    end
  end
end

function roomRoundTimeout(page)
  if not page.state.fight then
    return false
  end

  if not page.state.roundStartTime then
    page.state.roundStartTime = UI.now
  end

  if page.state.roundStartTime + ROUND_TIMEOUT * 1000 < UI.now then
    return true
  end

  return false
end

function haveAllPeopleSubmittedRoundActions(page)
  if roomRoundTimeout(page) then
    return true
  end

  for _, personInRoom in ipairs(page.state.people) do
    if not personInRoom.action and not personInRoom.isMonster then
      return false
    end
  end

  return true
end

function checkAllRoomsForFightTimeout(msg)
  UI.log("tm_check", UI.now)
  for _, page in ipairs(UI_APP.PAGES) do
    if page.state and page.state.fight then
      if roomRoundTimeout(page) then
        -- UI.log("tm_check", "Room timeout: " .. page.path)
        roomUpdateState(page)
      end
    end
  end
end

function isMonsterScared(personInRoom)
  local lowHelth = personInRoom.isMonster and personInRoom.hp < personInRoom.maxHp / 3
  local oneInFour = math.random(4) == 1
  return lowHelth and oneInFour
end

function selectRandomExit(page)
  local exits = {}
  for dir, path in pairs(page.exits) do
    table.insert(exits, dir)
  end

  return exits[math.random(#exits)]
end

function findAnotherVictimInRoomFor(pid, page)
  for _, personInRoom in ipairs(page.state.people) do
    if personInRoom.pid ~= pid then
      return personInRoom.pid
    end
  end
  return nil
end

function isMonsterAgressive(personInRoom)
  if personInRoom.type == 'good' then
    return false
  end
  return math.random(2) == 1
end

function setMonstersAction(page)
  for _, personInRoom in ipairs(page.state.people) do
    if personInRoom.isMonster then
      if isMonsterScared(personInRoom) then
        personInRoom.action = 'run'
        personInRoom.actionTm = UI.now
        personInRoom.actionDirection = selectRandomExit(page)
      else
        if personInRoom.actionTargetPid then
          personInRoom.action = 'attack'
          personInRoom.actionTm = UI.now
        else
          local targetPid = findAnotherVictimInRoomFor(personInRoom.pid, page)
          if targetPid and isMonsterAgressive(personInRoom) then
            personInRoom.action = 'attack'
            personInRoom.actionTm = UI.now
            personInRoom.actionTargetPid = targetPid
          end
        end
      end
    end
  end
end

function roomUpdateState(page)
  -- perform attacks (TODO: later sort by speed)
  -- for now perform random shuffle

  if page.state.beingUpdated then return end
  page.state.beingUpdated = true

  setMonstersAction(page)

  local fight = isRoomInFight(page)

  if fight and haveAllPeopleSubmittedRoundActions(page) then
    performRoomActions(page)
    page.state.roundStartTime = UI.now
  end

  fight = isRoomInFight(page)

  if not page.state.fight and fight then
    addRoomMessage(page, "Fight started")
    page.state.fight = true
    page.state.roundStartTime = UI.now
  end

  if page.state.fight and not fight then
    addRoomMessage(page, "Fight ended")
    -- clear all actions and targets for people in room

    for _, personInRoom in ipairs(page.state.people) do
      personInRoom.action = nil
      personInRoom.actionDirection = nil
      personInRoom.actionTargetPid = nil
    end

    page.state.fight = false
    page.state.roundStartTime = nil
  end

  UI.sendPageState(page)
  page.state.beingUpdated = false
end

function attack(attackerPid, targetPid)
  local attacker = UI_STATE[attackerPid]
  local target = UI_STATE[targetPid]

  if not attacker or not target then
    UI.log("attack", "Invalid pids: " .. attackerPid .. "/" .. targetPid)
    return ''
  end

  local halfAttackerStr = (attacker.str + attacker.weapon.str) / 2
  local targetDefence = target.defence

  if target.armor and target.armor.defence > 0 then
    -- if target evades:
    if target.action == 'evade' then
      targetDefence = target.defence + target.armor.defence / 2 + math.random(math.max(target.armor.defence / 2, 2))
    else
      local halfTotalDefence = (target.armor.defence + target.defence) / 2
      targetDefence = halfTotalDefence + math.max(halfTotalDefence / 2, 2)
    end
  end

  local damage = math.max(0, math.floor(halfAttackerStr + math.random(halfAttackerStr) - targetDefence))

  -- UI.log("attack", string.format("Attacker: %s, Target: %s, AttackerStr: %d + %d, TargetDefence: %d + %d, Damage: %d",
  --   attacker.name, target.name, attacker.str, attacker.weapon.str, target.defence, target.armor.defence, damage))

  local targetAlreadyDead = target.hp <= 0

  local page = UI.findPage(attacker.room)

  if not page then
    UI.log("attack", "Page not found: " .. attacker.room)
    return ''
  end


  if targetAlreadyDead then
    addRoomMessage(page,
      string.format("%s attacked %s's corpse with their %s", attacker.name, target.name, attacker.weapon.name))
    return ''
  end

  if target.room ~= attacker.room then
    addRoomMessage(page, string.format("%s has gone and %s looks upset", target.name, attacker.name))
    return ''
  end

  if target.action == 'evade' then
    addRoomMessage(page,
      string.format("%s tried to evade %s's attack", target.name, attacker.name))
  end

  if damage > 0 then
    addRoomMessage(page,
      string.format("%s attacked %s by %d hp with their %s", attacker.name, target.name, damage, attacker.weapon.name))
  else
    addRoomMessage(page, string.format("%s missed %s", attacker.name, target.name))
    return ''
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
  if page.customNavigation and not page.state.fight then
    return page.customNavigation
  end

  function btn(dir, title, empty)
    local variant = empty and 'outlined' or 'flat'
    local cmd = empty and 'cmdBuild' or 'cmdGo'
    local color = empty and 'grey' or '#4f545c'

    return string.format([[
      <v-tooltip text="%s">
        <template v-slot:activator="{ props }">
          <ui-button
            :color="state.ui.actionDirection === '%s' ? 'primary' : '%s'"
            variant="%s"
            v-bind="props"
            ui-run="%s({ dir = '%s' })">
          %s
          </ui-button>
        </template>
      </v-tooltip>
      ]], title, dir, color, variant, cmd, dir, dir)
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
  local target = '((page.people || []).find((p) => p.pid === person.actionTargetPid))?'

  function personName(fightMode)
    local inlineHitpoints = ''

    if fightMode then
      inlineHitpoints = [[ [{{ person.hp }}/{{ person.maxHp }}] ]]
    end

    return string.format(
      [[
        <v-tooltip location="top">
          <template v-slot:activator="{ props }">
            <span v-bind="props">
              <b>{{ person.name }}</b>
              <span class="text-caption text-grey">%s</span>
            </span>
          </template>
          <div class="ma-5">
          <table>
          <tr>
              <td colspan="2"><b>{{ person.name }}</b></td>
          </tr>
          <tr><td colspan="2" style="height: 1em"></td></tr>
          <tr>
              <td>Level / Exp:</td>
              <td style="text-align: right;">{{ person.level }} / {{ person.exp }}</td>
          </tr>
          <tr>
              <td>Gold:</td>
              <td style="text-align: right;">{{ person.gold }}</td>
          </tr>
          <tr>
              <td>Hitpoints:</td>
              <td style="text-align: right;">{{ person.hp }} / {{ person.maxHp }}</td>
          </tr>
          <tr v-if="!person.isMonster">
              <td>Strength:</td>
              <td style="text-align: right;">{{ person.str }}</td>
          </tr>
          <tr>
              <td>Weapon:</td>
              <td style="text-align: right;">{{ person.weapon.name }} [ + {{ person.weapon.str }} ]</td>
          </tr>
          <tr>
              <td>Armor:</td>
              <td style="text-align: right;">{{ person.armor.name }} [ + {{ person.armor.defence }} ]</td>
          </tr>
          </table>
          </div>
        </v-tooltip>
      ]], inlineHitpoints)
  end

  local personLine = string.format([[
    <div>
      <span>%s</span>
      <span> is here </span>
      <span v-if="! person.action">deciding what to do</span>
      <span v-else-if="person.action === 'attack'">
        going to attack
        <span v-if="person.actionTargetPid">
          <b :style="`color: ${ person.actionTargetPid === state.ui.pid ? 'red' : 'unset' }`">{{ %s.name }}</b>
        </span>
      </span>
      <span v-else-if="person.action === 'run'">running away</span>
      <span v-else-if="person.action === 'evade'">trying to evade</span>
      </div>
  ]], personName(page.state.fight), target)

  return string.format([[
      <div v-if="page.fight">
          <div v-for="person in (page.people || []).filter((p) => p.pid === state.ui.pid)" :key="person.pid" class="d-flex align-center">
            <div>
              <ui-button
                class="mr-2"
                :color="person.action === 'evade' ? 'primary' : undefined"
                :variant="person.action === 'evade' ? 'flat' : 'outlined'"
                ui-run="cmdEvade"
                :ui-args="{ target: person.pid }"
              >🛡️</ui-button>
            </div>
            %s
          </div>
          <div v-for="person in (page.people || []).filter((p) => p.pid !== state.ui.pid)" :key="person.pid" class="d-flex align-center">
            <div>
              <ui-button
                class="mr-2 mt-1"
                :color="state.ui.action === 'attack' && state.ui.actionTargetPid === person.pid ? 'primary' : undefined"
                :variant="state.ui.action === 'attack' && state.ui.actionTargetPid === person.pid ? 'flat' : 'outlined'"
                ui-run="cmdAttack"
                :ui-args="{ target: person.pid }"
              >⚔️</ui-button>
            </div>
            %s
            <v-progress-circular v-if="!person.isMonster && !person.action" class="ml-2" indeterminate size="small" color="primary"></v-progress-circular>
          </div>
          <div class="mt-2">
            <ui-timer class="text-caption" :timestampEnd="(page.roundStartTime || 0) + %d" ui-run="cmdRoomState" ></ui-timer>
          </div>
      </div>
      <div v-else>
          <div v-for="person in (page.people || [])" :key="person.pid">
            %s is here with a {{ { Apple: '🍎', Banana: '🍌', Cherry: '🍒', Mango: '🥭', Watermelon: '🍉', Pineapple: '🍍', Strawberry: '🍓', Kiwi: '🥝', Grapes: '🍇', Orange: '🍊', Peach: '🍑', Pear: '🍐', Plum: '🍑', Lemon: '🍋', Lime: '🍈', Coconut: '🥥', Pomegranate: '🥭', Blueberry: '🫐', Raspberry: '🍇', Blackberry: '🫐', Cranberry: '🍒', Gooseberry: '🍇', Apricot: '🍑', Papaya: '🥭' }[person.fruit] || person.fruit }}
          </div>
      </div>
      ]], personLine, personLine, ROUND_TIMEOUT * 1000, personName())
end

function roomLayoutMessages(page)
  return string.format([[
      <div
        v-for="(message, index) in (page.messages || [])"
        :key="`${message.t}-${index}-${message.text}`"
        :style="{ opacity: Math.max(0.1, 1 - (Number(%s) - Number(message.t)) / 1000000) }"
      >
        {{ message.text }}
      </div>
    ]], UI.now)
end

function roomLayoutEnvironment(page, pid)
  local res = ''

  local currentTerrain = page.state.terrain
  local playersBreadcrumbs = pid and UI_STATE[pid].breadcrumbs

  if playersBreadcrumbs then
    for terrain, path in pairs(playersBreadcrumbs) do
      if terrain ~= currentTerrain then
        local breadcrumbPage = path and UI.findPage(path)
        if breadcrumbPage then
          res = res .. string.format([[
          <v-tooltip text="%s" location="bottom">
            <template v-slot:activator="{ props }">
              <ui-button
                :style="{ fontSize: '40px' }"
                variant="plain"
                v-bind="props"
                ui-run="cmdGo"
                :ui-args="{ dir: '%s' }"
              >%s</ui-button>
            </template>
          </v-tooltip>
        ]], breadcrumbPage.title, path, Terrain[terrain] or breadcrumbPage.title)
        end
      end
    end
  end

  if page.environment then
    for _, env in ipairs(page.environment) do
      res = res .. string.format([[
          <v-tooltip text="%s" location="bottom">
            <template v-slot:activator="{ props }">
              <ui-button :style="{ fontSize: '40px' }" variant="plain" v-bind="props" ui-run="cmdGo" :ui-args="{ dir: '%s' }">%s</ui-button>
            </template>
          </v-tooltip>
      ]], env.title, env.path, env.icon or env.title)
    end
  end


  if res ~= '' then
    res = '<div class="d-flex" style="height: 54px">' .. res .. '</div>'
  end

  return res
end

function roomLayout(page, html, pid)
  local res = '<h1>' .. page.title .. '</h1>'

  res = res .. '<div class="mb-4 mt-4">' .. (html or page.html or '') .. '</div>'

  if not page.state.fight then
    res = res .. roomLayoutEnvironment(page, pid)
  end

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

function roomLayoutHospital(page, origHtml, forPid)
  local state = UI_STATE[UI.currentPid]
  local pid = UI.currentPid

  local hpToHeal = state.maxHp - state.hp
  local cost = hpToHeal * state.level * 10

  local verdict = "You look fine to us, they tell you."
  if state.hp < state.maxHp then
    verdict = string.format("We can fix you. It will cost you %d gold.", cost)
  end

  local healButton = ""
  if state.hp < state.maxHp then
    healButton = [[
      <ui-button ui-run="cmdHeal" class="mr-2">Heal</ui-button>
    ]]
  end

  local leaveButton = [[
    <ui-button ui-run="cmdGo({ dir = 'n' })">Leave</ui-button>
  ]]

  local navigation = string.format([[<div class="d-flex">%s %s</div>]], healButton, leaveButton)

  local html = string.format([[
    <p>
      You find yourself in the hospital. Young attractive nurses are walking around.
    </p>
    <p class="mb-4">%s</p>
  ]], verdict)

  page.customNavigation = navigation

  return roomLayout(page, html, pid)
end

function roomLayoutFountain(page, origHtml, forPid)
  local pid = UI.currentPid

  local html = string.format([[
    <div>
      You find yourself near the fountain. Beloved place for citizens to relax.
      The sign says: Swimming and drinking from the fountain is prohibited.
    </div>
    <div class="mt-4">
      <ui-input ui-id="chat" label="Chat" ui-type="String" ui-required></ui-input>
      <ui-button ui-run="cmdChat({ text = $chat })" ui-valid="chat">Say</ui-button>
    </div>
  ]])

  page.customNavigation = [[
    <div class="d-flex">
    <ui-button class="mr-2" ui-run="cmdDrinkFountain">Drink</ui-button>
    <ui-button class="mr-2" ui-run="cmdSwimFountain()">Swim</ui-button>
    <ui-button ui-run="cmdGo({ dir = 'n' })">Leave</ui-button>
    </div>
  ]]

  return roomLayout(page, html, pid)
end

function cmdChat(args)
  if isPlayerDead() then return deadPlayerRedirect() end

  local page = UI.currentPage()
  local pid = UI.currentPid

  addRoomMessage(page, string.format("%s says: %s", UI_STATE[pid].name, args.text))

  UI.sendPageState(page, pid)
  return UI.fullResponse()
end

function cmdDrinkFountain(args)
  if isPlayerDead() then return deadPlayerRedirect() end

  local page = UI.currentPage()
  local pid = UI.currentPid

  local state = UI_STATE[pid]
  local chance = math.random(3)

  if chance == 1 then
    state.hp = math.min(state.hp + 1, state.maxHp)
    addRoomMessage(page, string.format("%s drinks from the fountain and feels refreshed", state.name))
  else
    state.hp = math.min(state.hp - 3, 0)
    addRoomMessage(page, string.format("%s drinks from the fountain and vomits on the ground", state.name))

    if state.hp <= 0 then
      killPerson(pid)
      addRoomMessage(page, string.format("%s died after drinking from the fountain.", state.name))
    end
  end

  UI.sendPageState(page, pid)
  return UI.fullResponse()
end

-- swim in fountain. 50/50 chance of loosing helth or gaining exp: (current level * 2) or gaining gold (current level * 8)

function cmdSwimFountain(args)
  if isPlayerDead() then return deadPlayerRedirect() end

  local page = UI.currentPage()
  local pid = UI.currentPid

  local state = UI_STATE[pid]
  local chance = math.random(3)

  if chance < 2 then
    state.hp = math.max(state.hp - 2, 0)
    state.charm = math.max(state.charm - 1, 0)

    addRoomMessage(page, string.format("%s gets a strange itching from swimming in the fountain!", state.name))

    if state.hp <= 0 then
      killPerson(pid)
      addRoomMessage(page, string.format("%s died from swimming in the fountain", state.name))
      UI.sendPageState(page)
      return UI.fullResponse()
    end
  end

  chance = math.random(2)

  if chance == 1 then
    state.exp = state.exp + state.level * 2
    addRoomMessage(page, string.format("%s swims in the fountain and gains %d exp", state.name, state.level * 2))
  else
    local gainGold = 1 + math.random(state.level * 8)
    state.gold = state.gold + gainGold
    addRoomMessage(page, string.format("%s dives into the fountain and finds %d 🪙", state.name, gainGold))
  end

  UI.sendPageState(page, pid)
  return UI.fullResponse()
end

function renderShopParts(pid, itemType)
  -- filter item list according to its level vs user level
  local player = UI_STATE[pid]
  local items = {}

  for _, item in ipairs(ShopItems) do
    if
        item.type == itemType and
        item.price > 0 and
        item.level >= player.level - 1 and
        item.level <= player.level + 1
    then
      table.insert(items, item)
    end
  end

  local numFields = 0

  for _, field in ipairs(ShopItemTypes[itemType].fields) do
    numFields = numFields + 1
  end

  -- table with name, fields and price

  local table = [[
    <table>
      <tr>
        <th class="px-2">Item</th>
  ]]

  for _, field in ipairs(ShopItemTypes[itemType].fields) do
    table = table .. string.format('<th class="px-2">%s</th>', field.title)
  end

  table = table .. '<th class="px-2">Price 🪙</th></tr>'

  for _, item in ipairs(items) do
    table = table .. '<tr>'
    table = table .. string.format('<td class="px-2">%s</td>', item.name)

    for _, field in ipairs(ShopItemTypes[itemType].fields) do
      table = table .. string.format('<td class="px-2">%d</td>', item[field.field])
    end

    table = table .. string.format('<td class="px-2">%d</td>', item.price)
    table = table .. '</tr>'
  end

  table = table .. '</table>'

  -- select item

  local itemItems = ''
  for _, item in ipairs(items) do
    itemItems = itemItems .. string.format("'%s',", item.name)
  end

  local actions = string.format([[
    <div>
      <div>
        <ui-input
          ui-id="item"
          ui-type="Select"
          ui-required
          label="Item"
          :items="[%s]"
        ></ui-input>
      </div>
      <div class="d-flex">
      <ui-button
        class="mr-2"
        ui-run="cmdBuyItem({ item: $item })"
        ui-valid="item"
      >Buy</ui-button>
      <ui-button
        class="mr-2"
        ui-run="cmdSellItem({ item: $item })"
        ui-valid="item"
      >Sell</ui-button>
      <ui-button ui-run="cmdGo({ dir = 'n' })">Leave</ui-button>
      </div>
    </div>
  ]], itemItems)

  return { table = table, actions = actions }
end

function roomLayoutWeaponShop(page, origHtml, pid)
  local shop = renderShopParts(pid, 'weapon')

  page.customNavigation = shop.actions

  local html = string.format([[
    <p>
      You are in the weapon shop. The smell of metal and oil fills the air.
      Shops owner is here, looking at you with a smile of a maniac.
      Here's what i have for you:
    </p>
    <div class="mt-2">%s</div>
  ]], shop.table)

  return roomLayout(page, html, pid)
end

--[[

Armor = {
  { name = "Nothing", price = 0, defence = 0 },
  { name = "Traveler's Robe", price = 200, defence = 1 },
  ..
}
]]
--

function roomLayoutArmorShop(page, origHtml, pid)
  local shop = renderShopParts(pid, 'armor')

  page.customNavigation = shop.actions

  local html = string.format([[
    <p>
      You are in the armor shop. The smell of oil and leather fills the air.
      The owner is here, polishing a breastplate.
      Here's what i have for you:
    </p>
    <div class="mt-2">%s</div>
  ]], shop.table)

  return roomLayout(page, html, pid)
end

function createRoom(parentPagePath, direction, title, description, state)
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

  -- merge state if defined

  if state then
    for k, v in pairs(state) do
      page.state[k] = v
    end
  end

  return path
end

--

function removePersonFromRoom(page, pid, toDirection)
  if not page.state.people then return end
  local wasUpdate = false

  for i, person in ipairs(page.state.people) do
    if person.pid == pid then
      person.room = nil
      table.remove(page.state.people, i)
      wasUpdate = true
    end
  end

  pageOnPersonLeave(page, pid, toDirection)

  if wasUpdate then
    UI.sendPageState(page)
  end

  return wasUpdate
end

function createRoomPersonEntry(pid)
  local state = UI_STATE[pid]
  if not state then
    error("Person state not found " .. pid)
    return {}
  end
  state.room = state.path
  state.action = state.action or nil
  state.actionDirection = state.actionDirection or nil
  state.actionTargetPid = state.actionTargetPid or nil
  return state
end

function putPersonToRoom(page, pid, fromDirection)
  if not page.state.people then page.state.people = {} end

  -- check that person already in room
  for _, person in ipairs(page.state.people) do
    if person.pid == pid then return false end
  end

  local person = createRoomPersonEntry(pid)

  table.insert(page.state.people, person)

  person.room = page.path
  person.path = page.path

  -- update breadcrumbs
  if page.state.terrain and not page.state.noBreadcrumb then
    UI_STATE[pid].breadcrumbs[page.state.terrain] = page.path
  end

  pageOnPersonEnter(page, pid, fromDirection)

  UI.sendPageState(page)

  return true
end

function clearActions(page, pid)
  local peopleEntry = findPersonInRoom(page, pid)
  if not peopleEntry then return end

  peopleEntry.action = nil
  peopleEntry.actionDirection = nil
  peopleEntry.actionTargetPid = nil
end

function personGo(direction, pid)
  local page = UI.findPage(UI_STATE[pid].room)
  if not page then return error("Person room not found") end

  clearActions(page, pid)

  local exit = not direction:match('^/') and page.exits[direction]
  if not exit then
    exit = direction
    direction = nil
  end

  if not exit then return error("No exit in that direction") end

  local newPage = UI.findPage(exit)
  if not newPage then return error("Dst room not found") end

  if (page.state.fight) then
    addRoomMessage(page, string.format("%s ran away towards %s", UI_STATE[pid].name, newPage.title or 'somewhere'))
  end

  local person = findPersonInRoom(page, pid)
  if not person then return error("Person not found in room") end

  removePersonFromRoom(page, pid, direction)
  roomUpdateState(page)

  putPersonToRoom(newPage, pid, direction and OPOSITES[direction])
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

      local monstersInRoom = 0
      local maxMonsters = tonumber(page.state.maxMonsters or 0)

      for _, person in ipairs(page.state.people) do
        if person.isMonster then
          monstersInRoom = monstersInRoom + 1
        end
      end

      if monstersInRoom < maxMonsters then
        if level and level ~= 0 then
          spawnMonster(level, page)
          monstersInRoom = monstersInRoom + 1
        end
      end

      if monstersInRoom < maxMonsters then
        local terrainMobs = {}

        for _, mob in ipairs(Mobs) do
          if mob.terrain == page.state.terrain then
            table.insert(terrainMobs, mob)
          end
        end

        if #terrainMobs > 0 then
          local mob = terrainMobs[math.random(#terrainMobs)]
          if (mob.unique) then
            mob.pid = mob.name
          end
          spawnMonster(mob.level, page, mob)
        end
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

  local page = UI.findPage(UI_STATE[attackerPid].room)
  if not page then return error("Attacker room not found") end

  -- find in people array by pid
  local peopleEntry = findPersonInRoom(page, attackerPid)
  if not peopleEntry then return error("Attacker not found in room page=" .. page.path .. " aPid=" .. attackerPid) end

  peopleEntry.actionTargetPid = targetPid
  peopleEntry.action = 'attack'
  peopleEntry.actionTm = UI.now
  peopleEntry.actionDirection = nil
end

function roundActionEvade(pid)
  local page = UI.findPage(UI_STATE[pid].room)
  if not page then return error("User room not found") end

  local peopleEntry = findPersonInRoom(page, pid)
  if not peopleEntry then return error("Evade: User not found in room") end

  peopleEntry.action = 'evade'
  peopleEntry.actionDirection = nil
  peopleEntry.actionTm = UI.now
  peopleEntry.actionTargetPid = nil
end

function roundActionRun(pid, direction)
  local page = UI.findPage(UI_STATE[pid].room)
  if not page then return error("User room not found") end

  local peopleEntry = findPersonInRoom(page, pid)
  if not peopleEntry then return error("Run: User not found in room") end

  peopleEntry.action = 'run'
  peopleEntry.actionDirection = direction
  peopleEntry.actionTm = UI.now
  peopleEntry.actionTargetPid = nil
end

-- FROM HTML COMMANDS ---

function cmdBuyItem(args)
  local item = args.item
  local pid = UI.currentPid
  local player = UI_STATE[pid]
  local page = UI.findPage(player.room)

  local itemToBuy = nil
  for _, shopItem in ipairs(ShopItems) do
    if shopItem.name == item then
      itemToBuy = shopItem
      break
    end
  end

  if not itemToBuy then
    addRoomMessage(page, string.format("We dont have this here owner says to %s", player.name))
    return UI.fullResponse()
  end

  -- if price is 0 - laugh at player
  if itemToBuy.price == 0 then
    addRoomMessage(page, string.format("You kidding me the owner says to %s", player.name))
    return UI.fullResponse()
  end


  if player.gold < itemToBuy.price then
    addRoomMessage(page,
      string.format("You dont have enough gold to buy %s, owner says to %s", itemToBuy.name, player.name))
    return UI.fullResponse()
  end

  -- check if player already has item of this type
  local hasItem = player[itemToBuy.type] and player[itemToBuy.type].price > 0
  -- if has owner demands to sell it first

  if hasItem then
    addRoomMessage(page,
      string.format("You already have %s! Said owner to %s. Sell one first", itemToBuy.type, player.name))
    return UI.fullResponse()
  end

  player[itemToBuy.type] = itemToBuy
  player.gold = player.gold - itemToBuy.price

  addRoomMessage(page, string.format("%s bought %s for %d 🪙", player.name, itemToBuy.name, itemToBuy.price))

  return UI.fullResponse()
end

function cmdSellItem(args)
  local item = args.item
  local pid = UI.currentPid
  local player = UI_STATE[pid]
  local page = UI.findPage(player.room)

  local itemToSell = nil
  for _, shopItem in ipairs(ShopItems) do
    if shopItem.name == item then
      itemToSell = shopItem
      break
    end
  end

  if not itemToSell then
    addRoomMessage(page, string.format("We dont buy such here owner says to %s", player.name))
    return UI.fullResponse()
  end

  -- if price is 0 - laugh at player
  if itemToSell.price == 0 then
    addRoomMessage(page, string.format("You kidding me the owner says to %s", player.name))
    return UI.fullResponse()
  end

  -- check if player has this item
  local hasItem = player[itemToSell.type] and player[itemToSell.type].name == itemToSell.name

  if not hasItem then
    addRoomMessage(page, string.format("You dont have %s to sell, says owner to %s", itemToSell.name, player.name))
    return UI.fullResponse()
  end

  player[itemToSell.type] = ShopItemTypes[itemToSell.type].none
  player.gold = player.gold + itemToSell.price

  addRoomMessage(page, string.format("%s sold %s for %d 🪙", player.name, itemToSell.name, itemToSell.price))

  return UI.fullResponse()
end

function cmdHeal()
  local state = UI_STATE[UI.currentPid]
  local page = UI.findPage(state.path)

  local hpToHeal = state.maxHp - state.hp
  local costPerPoint = state.level * 10

  local pointsCanBeHealed = math.min(hpToHeal, math.floor(state.gold / costPerPoint))
  local cost = pointsCanBeHealed * costPerPoint

  if pointsCanBeHealed <= 0 then
    addRoomMessage(page, string.format("%s tried to heal, but didn't have enough gold", state.name))
    roomUpdateState(page)
    return UI.page({ path = state.path }) .. UI.pageState(page) .. UI.state()
  end

  UI.set({
    hp = state.hp + pointsCanBeHealed,
    gold = state.gold - cost,
  })

  addRoomMessage(page, string.format("%s healed %d hp for %d gold", state.name, pointsCanBeHealed, cost))
  roomUpdateState(page)

  return UI.page({ path = state.path }) .. UI.pageState(page) .. UI.state()
end

function isPlayerDead()
  return UI_STATE[UI.currentPid].hp <= 0
end

function deadPlayerRedirect()
  UI.set({
    hp = 1,
  });

  local spawnRoom = UI.findPage('/hospital')
  local state = UI_STATE[UI.currentPid]

  putPersonToRoom(spawnRoom, UI.currentPid)
  addRoomMessage(spawnRoom, string.format("%s has been ressurected by the gods", state.name))
  roomUpdateState(spawnRoom)

  return UI.page({ path = '/hospital' }) .. UI.pageState(spawnRoom) .. UI.state()
end

function cmdBuild(args)
  if isPlayerDead() then return deadPlayerRedirect() end

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
  if isPlayerDead() then return deadPlayerRedirect() end

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
  if isPlayerDead() then return deadPlayerRedirect() end

  local targetPid = args.target

  if not targetPid then return error("No target") end

  roundActionAttack(UI.currentPid, targetPid)

  local page = UI.findPage(UI.currentPath())

  roomUpdateState(page)

  return UI.page({ path = UI.currentPath() }) .. UI.pageState(page) .. UI.state()
end

function cmdEvade(args)
  if isPlayerDead() then return deadPlayerRedirect() end

  roundActionEvade(UI.currentPid)

  local page = UI.findPage(UI.currentPath())

  roomUpdateState(page)

  return UI.page({ path = UI.currentPath() }) .. UI.pageState(page) .. UI.state()
end

function cmdGo(args)
  if isPlayerDead() then return deadPlayerRedirect() end

  local direction = args.dir

  local page = UI.findPage(UI.currentPath())

  if page.state.fight then
    roundActionRun(UI.currentPid, direction)
    roomUpdateState(page)
    -- room could change

    local state = UI_STATE[UI.currentPid]
    local newPage = UI.findPage(state.room or state.path) -- room could be nil if player is dead
    if not newPage then return error("Room not found") end

    return UI.page({ path = newPage.path }) .. UI.pageState(newPage) .. UI.state()
  end

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

function cmdRoomState()
  local page = UI.findPage(UI.currentPath())
  roomUpdateState(page)
  return UI.page({ path = UI.currentPath() }) .. UI.pageState(page) .. UI.state()
end

Handlers.add("CronMessage", Handlers.utils.hasMatchingTag("Cron", "Cron"),
  function(msg)
    UI.now = tonumber(msg.Timestamp)
    local status, err = pcall(checkAllRoomsForFightTimeout, msg)
    if not status then
      UI.log("Cron", "Error: " .. err)
    end
  end
)

Handlers.add(
  "AnyMessage",
  function(msg)
    return "continue"
  end,
  function(msg)
    UI.now = tonumber(msg.Timestamp)
    local status, err = pcall(checkAllRoomsForFightTimeout, msg)
    if not status then
      UI.log("AnyMessage", "Error: " .. err)
    end
  end
)
