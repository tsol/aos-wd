-- Crosshair gang bot (c) TSOL

Game = "{{gamePid}}"
CredPid = "{{credPid}}"
CredAmount = "{{credAmount}}"

LatestGameState = LatestGameState or nil
InAction = InAction or false -- not using

Logs = Logs or {}

State = {
  mode = 'waiting',
  targetXY = { x = 20, y = 20 },
  victim = nil,

  friends = {},
  requestedFriends = false,
  steppingTo = nil
}


-- TSOL Common

Colors = Colors or {
  red = "\27[31m",
  green = "\27[32m",
  blue = "\27[34m",
  reset = "\27[0m",
  gray = "\27[90m"
}

-- compatability with any Lua environment
Handlers = Handlers or {
  utils = { hasMatchingTag = function(tag, val) end },
  add = function(name, check, exec) end,
  remove = function(name) end
}
ao = ao or { send = function(obj) end, id = "unknown" }
undefined = undefined or "undefined"

-- my syntax sugar
TAGS = Handlers.utils.hasMatchingTag
HANDLER = Handlers.add
SEND = ao.send
ME = ao.id

-- Migration

Handlers.remove("decideNextAction")


function OnPing(msg)
  print(Colors.blue .. "Ping from " .. msg.From .. Colors.reset)
end

HANDLER("OnPing", TAGS("Action", "Ping"),
  function(msg)
    OnPing(msg)
  end
)

function resetState()
  State = {
    mode = 'waiting',
    targetXY = { x = 0, y = 0 },
    victim = nil,
    friends = {},
    requestedFriends = false,
    steppingTo = nil
  }
  print(Colors.green .. "State reset." .. Colors.reset)
end

function setVictim(pid)
  State.victim = pid
end

function reSortFriends()
  local friendsArray = {}
  for k, v in pairs(State.friends) do
    table.insert(friendsArray, k)
  end

  table.sort(friendsArray)

  for i, v in ipairs(friendsArray) do
    if not State.friends[v] then
      State.friends[v] = {}
    end

    State.friends[v].index = i;
  end
end

function addFriend(pid)
  if not pid then
    print(Colors.red .. "Invalid PID." .. Colors.reset)
    return
  end

  if State.friends[pid] then
    print(Colors.red .. "Friend already added." .. Colors.reset)
    return
  end

  State.friends[pid] = { index = getNumberOfFriends() + 1 }

  reSortFriends()
  setVictim(findNextVictim())

  print(Colors.blue .. "Friend added: " .. pid .. Colors.reset)

end

-- send a message to all Players with action "Hello"
function makeFriends()
  if not LatestGameState then
    print(Colors.red .. "No game state to make friends." .. Colors.reset)
    return
  end

  for k, v in pairs(LatestGameState.Players) do
    if k ~= ME then
      SEND({ Target = k, Action = "Cok" })
    end
  end
end

function addLog(msg, text)
  Logs[msg] = Logs[msg] or {}
  table.insert(Logs[msg], text)
end

function inRange(x1, y1, x2, y2, range)
  return math.abs(x1 - x2) <= range and math.abs(y1 - y2) <= range
end

function friendInRange()
  if not LatestGameState then
    return false
  end

  local player = LatestGameState.Players[ME]

  for target, state in pairs(LatestGameState.Players) do
    if target ~= ME and inRange(player.x, player.y, state.x, state.y, 1) then
      if State.friends[target] then
        return true
      end
    end
  end
  return false
end

function enemyInRange()
  if not LatestGameState then
    return false
  end

  local player = LatestGameState.Players[ME]

  for target, state in pairs(LatestGameState.Players) do
    if target ~= ME and inRange(player.x, player.y, state.x, state.y, 1) then
      if not State.friends[target] then
        return true
      end
    end
  end
  return false
end

function isVictimAlive()
  if not LatestGameState then
    return false
  end

  return LatestGameState.Players[State.victim] ~= nil
end

function getFriendWithIndex(index)
  for k, v in pairs(State.friends) do
    if v.index == index then
      return k
    end
  end
  return nil
end

function findNextVictim()
  -- pick closest enemy

  if State.friends[ME] and State.friends[ME].index ~= 1 then
    print(Colors.red .. "Im not in charge here" .. Colors.reset)

    -- send to the first friend to find a new victim
    local firstFriend = getFriendWithIndex(1)

    if not firstFriend then
      print(Colors.red .. "No first friend found." .. Colors.reset)
      return nil
    end

    SEND({ Target = firstFriend, Action = "KillRequest" })

    return nil
  end

  local player = LatestGameState.Players[ME]

  local minDistance = 1000
  local closestEnemy = nil

  for target, state in pairs(LatestGameState.Players) do
    if target ~= ME and not State.friends[target] then
      local distance = math.abs(player.x - state.x) + math.abs(player.y - state.y)
      if distance < minDistance then
        minDistance = distance
        closestEnemy = target
      end
    end
  end

  if not closestEnemy then
    print(Colors.red .. "No more enemies found." .. Colors.reset)
    -- TODO suicide :)
    return nil
  end

  -- send all friends except me new victim

  for k, v in pairs(State.friends) do
    if k ~= ME then
      SEND({ Target = k, Action = "KILL", Victim = closestEnemy })
    end
  end

  return closestEnemy
end

function getNumberOfFriends()
  local count = 0
  for k, v in pairs(State.friends) do
    count = count + 1
  end
  return count
end

function calcAttackPosition(player, target)

  if not target or not player or not LatestGameState then
      print "calcAttack invalid args."
      return;
  end

  local numFriends = getNumberOfFriends()

  local resX = LatestGameState.Players[target].x
  local resY = LatestGameState.Players[target].y

  -- if no friends around, attack directly

  if numFriends <= 1 then
    return { x = resX, y = resY }
  end

  local attackOffsets = {
    { x = -1, y = -1 },
    { x = 1,  y = -1 },
    { x = 1,  y = 1 },
    { x = -1, y = 1 },
  }

  local myIndex = State.friends[player].index
  local myAttackOffset = attackOffsets[myIndex % 4 + 1]

  if (myIndex > 4) then
    local times = math.floor(myIndex / 4)
    myAttackOffset.x = myAttackOffset.x * times
    myAttackOffset.y = myAttackOffset.y * times
  end

  resX = resX + myAttackOffset.x
  resY = resY + myAttackOffset.y

  -- TODO: deal with out of bound values

  return { x = resX, y = resY }
end

function decideNextAction()
  if not LatestGameState then
    print(Colors.red .. "No game state available to decide action." .. Colors.reset)
    return
  end

  if LatestGameState.GameMode ~= "Playing" then
    print(Colors.gray .. "Game is not in playing mode. Nothing to decide." .. Colors.reset)
    return
  end

  if not LatestGameState.Players[ME] then
    print(Colors.red .. "Player not found in game state." .. Colors.reset)
    return
  end

  local player = LatestGameState.Players[ME]
  print("Deciding next action.")

  -- Make firends with all players
  if not State.requestedFriends then
    addFriend(ME)
    makeFriends()
    State.requestedFriends = true
  end

  -- remove dead friends
  local friendDied = false

  for k, v in pairs(State.friends) do
    if State.friends[k] and not LatestGameState.Players[k] then
      print(Colors.red .. "Friend " .. k .. " is dead." .. Colors.reset)
      State.friends[k] = nil
      friendDied = true
    end
  end

  if friendDied then
    reSortFriends()
  end

  local needToAttack = enemyInRange() and not friendInRange()

  if player.energy > 5 and needToAttack then
    print(Colors.red .. "Player in range. Attacking." .. Colors.reset)
    SEND({ Target = Game, Action = "PlayerAttack", Player = ME, AttackEnergy = tostring(player.energy) })
  end

  if State.victim then

    if isVictimAlive() then
      State.targetXY = calcAttackPosition(ME, State.victim)
      moveToTarget()
      return
    end

    print(Colors.red .. "Victim is dead." .. Colors.reset)
    setVictim(findNextVictim())
    
    return
  end

  print (Colors.gray .. "No victim found." .. Colors.reset)
  
end

function cmdGoTo(x, y)
  State.victim = nil
  State.targetXY = { x = x, y = y }
  State.mode = 'moving'
  moveToTarget()
end

function onTargetReached()
  print(Colors.green .. "NVG: Target reached." .. Colors.reset)
  State.mode = 'arrived'
end

function moveToTarget()
  local player = LatestGameState.Players[ME]
  local target = State.targetXY

  if not player or not target then
    print(Colors.red .. "Player or target not found." .. Colors.reset)
    return
  end

  if State.steppingTo then
    if math.floor(player.x) ~= math.floor(State.steppingTo.x) or math.floor(player.y) ~= math.floor(State.steppingTo.y) then
      print(Colors.gray .. "NVG: step still in progress..." .. Colors.reset)
      State.steppingTo["count"] = (State.steppingTo["count"] or 0) + 1
      if State.steppingTo["count"] > 3 then
        print(Colors.red .. "NVG: step timeout." .. Colors.reset)
        State.steppingTo = nil
      end

      return
    end
    State.steppingTo = nil
  end

  local dx = target.x - player.x
  local dy = target.y - player.y;

  -- print dx and dy
  print("NVG: dx: " .. dx .. " dy: " .. dy)

  if dx == 0 and dy == 0 then
    onTargetReached()
    return
  end

  moveDirection(dx, dy)
end

function moveDirection(x, y)
  local normX = 0
  if x ~= 0 then
    normX = x / math.abs(x)
  end

  local normY = 0
  if y ~= 0 then
    normY = y / math.abs(y)
  end

  local directionMap = {
    ["0,-1"] = "Up",
    ["1,0"] = "Right",
    ["-1,0"] = "Left",
    ["0,1"] = "Down",
    ["1,1"] = "DownRight",
    ["1,-1"] = "UpRight",
    ["-1,1"] = "DownLeft",
    ["-1,-1"] = "UpLeft"
  }

  local dirIndex = string.format("%d,%d", normX, normY);
  
  local direction = directionMap[dirIndex]

  if not direction then
    print(Colors.red .. "Invalid direction." .. Colors.reset)
    return
  end

  print (Colors.gray .. "NVG: Dir Index: " .. dirIndex .. " Dir:" .. direction .. Colors.reset)

  State.steppingTo = { x = LatestGameState.Players[ME].x + normX, y = LatestGameState.Players[ME].y + normY }
  SEND({ Target = Game, Action = "PlayerMove", Player = ME, Direction = direction })
end

function randomMove()
  print(Colors.gray .. "Random move" .. Colors.reset)
  local directionMap = { "Up", "Down", "Left", "Right", "UpRight", "UpLeft", "DownRight", "DownLeft" }
  local randomIndex = math.random(#directionMap)
  SEND({ Target = Game, Action = "PlayerMove", Player = ME, Direction = directionMap[randomIndex] })
end

function requestGameState(force)
  print(Colors.gray .. "Getting game state..." .. Colors.reset)
  SEND({ Target = Game, Action = "GetGameState" })
end

HANDLER("PrintAnnouncements", TAGS("Action", "Announcement"),

  function(msg)
    print(Colors.green .. msg.Event .. ": " .. msg.Data .. Colors.reset)

    if msg.Event == "Started-Waiting-Period" then
      print("Auto-paying confirmation fees.")
      SEND({ Target = CredPid, Action = "Transfer", Recipient = Game, Quantity = CredAmount })
    elseif (msg.Event == "Tick") then
      requestGameState()
    elseif (msg.Event == "Started-Game") then
      resetState()
      requestGameState()
    end
  end
)

HANDLER("UpdateGameState", TAGS("Action", "GameState"),
  function(msg)
    local json = require("json")
    LatestGameState = json.decode(msg.Data)
    if LatestGameState.GameMode == "Playing" then
      LatestGameState.BotState = State
    end
    print(json.encode(LatestGameState))
    SEND({ Target = ME, Action = "Tick" })
  end
)

HANDLER("GetGameStateOnTick", TAGS("Action", "Tick"),
  function()
    decideNextAction()
    requestGameState()
  end
)

HANDLER("ReturnAttack", TAGS("Action", "Hit"),
  function(msg)
    print(Colors.red .. "Got Hit" .. Colors.reset)
  end
)

HANDLER("Hello", TAGS("Action", "Cok"),
  function(msg)
    print(Colors.blue .. "Hello from " .. msg.From .. Colors.reset)
    addFriend(msg.From)
    SEND({ Target = msg.From, Action = "Guzel" })
  end
)

HANDLER("HelloResppnse", TAGS("Action", "Guzel"),
  function(msg)
    print(Colors.green .. "Hello response from " .. msg.From .. Colors.reset)
    addFriend(msg.From)
  end
)

HANDLER("NewVictim", TAGS("Action", "KILL"),
  function(msg)
    print(Colors.green .. "New victim order: " .. msg.Victim .. Colors.reset)
    setVictim(msg.Victim)
  end
)

HANDLER("KillRequest", TAGS("Action", "KillRequest"),
  function(msg)
    print(Colors.green .. "Kill request received." .. Colors.reset)
    SEND({ Target = msg.From, Action = "KILL", Victim = State.victim })
  end
)

-- Grid adaptation

HANDLER("ReSpawn", TAGS("Action", "Eliminated"),
  function (msg)
    print("Elminated! " .. "Playing again!")
    SEND({Target = CredPid, Action = "Transfer", Quantity = CredAmount, Recipient = Game})
  end
)

HANDLER("StartTick", TAGS("Action", "Payment-Received"),
  function (msg)
    resetState()
    requestGameState()
    print('Start Moooooving!')
  end
)

