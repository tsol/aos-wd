-- Crosshair Gang bot (for Grid) (c) TSOL

-- TODO:
-- Once on march (far from target) don't waste energy on attacking

Game = "{{gamePid}}"
CredPid = "{{credPid}}"
CredAmount = "{{credAmount}}"

LatestGameState = LatestGameState or nil
PlayerBalances = PlayerBalances or {}

Now = Now or undefined -- Current time, updated on every message.
LastRequestTime = LastRequestTime or undefined -- Last time we requested a game state.
LastResponseTime = LastResponseTime or undefined -- Last time we received a game state.

Logs = Logs or {}

State = State or {
  mode = 'waiting',
  targetXY = { x = 20, y = 20 },
  victim = nil,

  friends = {},
  requestedFriends = false,
  steppingTo = nil,
  notInGameCount = 0
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

-- Migrations

Handlers.remove("decideNextAction")
Handlers.remove("Game-State-Timers")


HANDLER("OnPing", TAGS("Action", "Ping"),
  function(msg)
    print(Colors.blue .. "Ping from " .. msg.From .. Colors.reset)
    -- safe call this:
    --updateTimerAntiStale(msg)

    local status, err = pcall(updateTimerAntiStale, msg)
    if not status then
      print(err)
      addLog("updateTimerAntiStale", err)
    end

  end
)

function updateTimerAntiStale(msg)

  if not msg.Timestamp then
    print(Colors.red .. "No timestamp in message." .. Colors.reset)
    return
  end

  Now = msg.Timestamp

  print( Colors.blue .. "Now: " .. Now .. Colors.reset)
 
  if not LatestGameState then
    requestGameState()
    return
  end

  local player = LatestGameState.Players[ME]
  if not player then
    requestGameState()
    return
  end

  local lastTurn = player.lastTurn

  if not lastTurn then
    requestGameState()
    return
  end

  for k, v in pairs(LatestGameState.Players) do
    if v.lastTurn and v.lastTurn > lastTurn then
      lastTurn = v.lastTurn
    end
  end

  local sinceLastMove = (Now - lastTurn) / 1000
  local sinceLastRequest = (Now - LastRequestTime) / 1000
  local sinceLastResponse = (Now - LastResponseTime) / 1000

  print (Colors.gray .. "Response: " .. sinceLastResponse .. " Request: " .. sinceLastRequest .. " Move: " .. sinceLastMove .. " seconds ago" .. Colors.reset)
  if sinceLastResponse >= 30 and sinceLastRequest >= 30 then
    print(Colors.red .. "Game state is stale. Requesting new one." .. Colors.reset)
    requestGameState()
  end
  
end

function pingAllFriendsExceptMe()

  print(Colors.blue .. "Pinging all friends." .. Colors.reset)
  for k, v in pairs(State.friends) do
    if k ~= ME then
      SEND({ Target = k, Action = "Ping" })
    end
  end
end

function resetState()
  State = {
    mode = 'waiting',
    targetXY = { x = 0, y = 0 },
    victim = nil,
    friends = {},
    requestedFriends = false,
    steppingTo = nil
  }
  PlayerBalances = {}
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

function victimInRange()
  if not LatestGameState then
    return false
  end

  local victim = LatestGameState.Players[State.victim]
  if not victim then
    return false
  end

  local player = LatestGameState.Players[ME]
  if inRange(player.x, player.y, victim.x, victim.y, 1) then
    return true
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

  if not State.victim then
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


function avarageDistanceFromFriendsToTarget(target)
  if not LatestGameState then
    return 0
  end

  local sum = 0
  local count = 0

  for k, v in pairs(State.friends) do
    if LatestGameState.Players[k] then
      sum = sum + math.abs(LatestGameState.Players[k].x - target.x) + math.abs(LatestGameState.Players[k].y - target.y)
      count = count + 1
    end
  end

  return sum / count
end

function victimIsWeak()
  if not LatestGameState then
    return false
  end

  if not State.victim then
    return false
  end

  local victim = LatestGameState.Players[State.victim]

  if not victim then
    return false
  end

  return victim.health < 10
end

function findNextVictim()
  -- pick closest enemy

  if not LatestGameState then
    print(Colors.red .. "No game state available to find next victim." .. Colors.reset)
    return nil
  end

  if State.friends[ME] and State.friends[ME].index ~= 1 then
    print(Colors.red .. "Im not in charge here" .. Colors.reset)

    -- send to the first friend to find a new victim
    local firstFriend = getFriendWithIndex(1)

    if not firstFriend then
      print(Colors.red .. "No first friend found." .. Colors.reset)
      return nil
    end

    SEND({ Target = firstFriend, Action = "KillRequest" })

    return State.victim
  end


  local minScore = 10000
  local closestEnemy = nil

  for target, state in pairs(LatestGameState.Players) do
    if target ~= ME and not State.friends[target] then
      local victim = LatestGameState.Players[target]

      local moneyCoef = (tonumber(PlayerBalances[target]) or 0) / 1000
      local healthCoef = math.exp(- victim.health / 25) * 50
      local energyCoef = math.exp(- victim.energy / 25) * 15
      local distanceCoef = avarageDistanceFromFriendsToTarget(state);

      local score = distanceCoef - healthCoef - energyCoef - moneyCoef;

      print (Colors.gray .. "Victim? " .. target .. " h: " .. healthCoef .. " e: " .. energyCoef .. " dst: " .. distanceCoef .. " crd:" .. moneyCoef .. " = " .. score .. Colors.reset)

      if score < minScore then
        minScore = score
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
    -- TODO: better logic here - for example infinite chess pattern 
    local times = math.ceil(myIndex / 4) + 1
    myAttackOffset.x = myAttackOffset.x * times
    myAttackOffset.y = myAttackOffset.y * times

    if victimIsWeak() then
      myAttackOffset.x = resX
      myAttackOffset.y = resY
    end

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

    State.notInGameCount = ( State.notInGameCount or 0 ) + 1
    if State.notInGameCount > 10 then
      State.notInGameCount = 0
      cmdPayForGrid()
      return
    end

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

  local needToAttack =  ( victimInRange() and victimIsWeak() ) or
                        ( enemyInRange() and not friendInRange())
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
    cmdGetBalances()
  end

  print (Colors.gray .. "No victim found." .. Colors.reset)
  setVictim(findNextVictim())
  
end

function cmdGoTo(x, y)
  State.victim = nil
  State.targetXY = { x = x, y = y }
  State.mode = 'moving'
  moveToTarget()
end

function cmdWithdraw()
  print(Colors.green .. "Withdrawing CRED." .. Colors.reset)
  SEND({ Target = Game, Action = "Withdraw"})
end

function onTargetReached()
  print(Colors.green .. "NVG: Target reached." .. Colors.reset)
  State.mode = 'arrived'
end

function moveToTarget()
  if not LatestGameState then
    print(Colors.red .. "No game state available to move to target." .. Colors.reset)
    return
  end

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
      if State.steppingTo["count"] > 10 then
        print(Colors.red .. "NVG: step timeout." .. Colors.reset)
        State.steppingTo = nil
      end

      return
    end
    print(Colors.green .. "NVG: step completed." .. Colors.reset)
    State.steppingTo = nil
  end

  local dx = target.x - player.x
  local dy = target.y - player.y;

  -- print("NVG: dx: " .. dx .. " dy: " .. dy)

  if dx == 0 and dy == 0 then
    onTargetReached()
    return
  end

  moveDirection(dx, dy)
end

function moveDirection(x, y)

  if not LatestGameState then
    print(Colors.red .. "No game state available to move." .. Colors.reset)
    return
  end

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

  State.steppingTo = { x = LatestGameState.Players[ME].x + normX, y = LatestGameState.Players[ME].y + normY }
  
  print (Colors.gray .. "NVG: step to (" .. State.steppingTo.x .. "," .. State.steppingTo.y .. "): " .. direction .. Colors.reset)

  SEND({ Target = Game, Action = "PlayerMove", Player = ME, Direction = direction })
end

function randomMove()
  print(Colors.gray .. "Random move" .. Colors.reset)
  local directionMap = { "Up", "Down", "Left", "Right", "UpRight", "UpLeft", "DownRight", "DownLeft" }
  local randomIndex = math.random(#directionMap)
  SEND({ Target = Game, Action = "PlayerMove", Player = ME, Direction = directionMap[randomIndex] })
end

function cmdGetBalances()
  print(Colors.gray .. "Getting balances..." .. Colors.reset)
  SEND({ Target = Game, Action = "Balances"})
end

function requestGameState()
  print(Colors.gray .. "Getting game state..." .. Colors.reset)
  SEND({ Target = Game, Action = "GetGameState" })
  LastRequestTime = Now
end

function parseGameState(msg)
  local json = require("json")
  LatestGameState = json.decode(msg.Data)
  if LatestGameState.GameMode == "Playing" then
    LatestGameState.BotState = State
    LatestGameState.PlayerBalances = PlayerBalances
  end

  print(json.encode(LatestGameState))
end

function cmdPayForGrid()
  print(Colors.green .. "Paying for grid." .. Colors.reset)
  SEND({ Target = CredPid, Action = "Transfer", Recipient = Game, Quantity = CredAmount })
end

function tableLength(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

function parseBalances(msg)
  local json = require("json")

  local prevBalancesWereEmpty = not PlayerBalances or tableLength(PlayerBalances) == 0
  PlayerBalances = json.decode(msg.Data)

  local numDefaultCred = tonumber(CredAmount) or 1000
  local myNewBalance = tonumber(PlayerBalances[ME]) or 0

  print(Colors.green .. "CRED total gained: " .. (myNewBalance - numDefaultCred) .. Colors.reset)
  if myNewBalance > numDefaultCred * 5 then
    cmdWithdraw()
  end
  if prevBalancesWereEmpty then
    -- select new victim
    setVictim(findNextVictim())
  end

end

HANDLER("PrintAnnouncements", TAGS("Action", "Announcement"),

  function(msg)
    print(Colors.green .. msg.Event .. ": " .. msg.Data .. Colors.reset)

    if msg.Event == "Started-Waiting-Period" then
      print("Auto-paying confirmation fees.")
      cmdPayForGrid()
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
    LastResponseTime = msg.Timestamp or Now

    local status, err = pcall(parseGameState, msg)
    if not status then
      print(err)
      addLog("parseGameState", err)
    end

    SEND({ Target = ME, Action = "Tick" })
  end
)

HANDLER("GetGameStateOnTick", TAGS("Action", "Tick"),
  function()
    local status, err = pcall(decideNextAction)
    if not status then
      print(err)
      addLog("decideNextAction", err)
    end
    requestGameState()
  end
)

HANDLER("ReturnAttack", TAGS("Action", "Hit"),
  function(msg)
    print(Colors.red .. "Got Hit" .. Colors.reset)
    requestGameState()
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
    requestGameState()
  end
)

-- Grid adaptation

HANDLER("ReSpawn", TAGS("Action", "Eliminated"),
  function (msg)
    print("Elminated! " .. "Playing again!")
    cmdPayForGrid()
  end
)

HANDLER("StartTick", TAGS("Action", "Payment-Received"),
  function (msg)
    resetState()
    requestGameState()
    cmdGetBalances()
    print('Start Moooooving!')
  end
)

HANDLER("Message", TAGS("Type", "Message"),
  function (msg)

    -- updateTimerAntiStale(msg)
    -- pingAllFriendsExceptMe()
    -- safe call them^

    local status, err = pcall(updateTimerAntiStale, msg)
    if not status then
      print(err)
      addLog("updateTimerAntiStale", err)
    end

    local status, err = pcall(pingAllFriendsExceptMe)
    if not status then
      print(err)
      addLog("pingAllFriendsExceptMe", err)
    end

    if string.sub(msg.Data, 1, 1) == "{" then
      local status, err = pcall(parseBalances, msg)
      if not status then
        print(err)
        addLog("parseBalances", err)
      end
      return
    end

    local x, y = string.match(msg.Data, "moved to (%d+),(%d+)")
    if x and y then
      x = tonumber(x)
      y = tonumber(y)

      print (Colors.blue .. "Player moved to: " .. x .. "," .. y .. Colors.reset)

      if not LatestGameState then
        print(Colors.red .. "No game state available to update player position." .. Colors.reset)
        return
      end

      LatestGameState.Players[ME].x = x
      LatestGameState.Players[ME].y = y
      return
    end

    print(Colors.gray .. "Message: " .. msg .. Colors.reset)

  end
)


