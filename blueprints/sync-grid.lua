-- Original grid code https://github.com/twilson63/grid/blob/main/grid.lua
-- Synced version by TSOL


-- compatability with any Lua environment
Handlers = Handlers or {
    utils = { hasMatchingTag = function(tag, val) end },
    add = function(name, check, exec) end,
    remove = function(name) end
  }
  ao = ao or { send = function(obj) end, id = "unknown" }
  Send = Send or function(obj) end
  undefined = undefined or "undefined"

-- Constants

Variant = "0.1-sync"
CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc"
PaymentQty = 10

MaximumPlayers = 35

Width = 40
Height = 40
Range = 3

MaxEnergy = 100
EnergyPerTurn = 1

AverageMaxStrengthHitsToKill = 3 -- Average number of hits to eliminate a player

-- Force turn after 120 seconds even if not all players have submitted actions
WaitTurnLimit = 120000

-- Game state

GameMode = GameMode or "Playing"

Now = Now or 0 -- Current time, updated on every message.

Players = Players or {}
Balances = Balances or {}
Listeners = Listeners or {}

-- Attack info
CurrentAttacks = CurrentAttacks or 0
LastPlayerAttacks = LastPlayerAttacks or {}

GameStateJson = GameStateJson or {} -- speed up things

Turn = Turn or {
    count = 0,
    lastTurn = 0,
    submittedActions = {},
    waitingFor = {},
    waitingCount = 0
}

Logs = {}

function addLog(msg, text)
  Logs[msg] = Logs[msg] or {}
  table.insert(Logs[msg], text)
end

function haveAllPlayersSubmittedActions()
    Turn.waitingFor = {}
    Turn.waitingCount = 0
    for k,v in pairs(Players) do
        if not Turn.submittedActions[k] then
            Turn.waitingFor[k] = true
            Turn.waitingCount = Turn.waitingCount + 1
        end
    end
    
    return Turn.waitingCount == 0
end

function addPlayerMoveAction(player, direction)
    if not Turn.submittedActions[player] then
        Turn.submittedActions[player] = {}
    end

    Turn.submittedActions[player].move = direction
end

function addPlayerAttackAction(player, attackEnergy)
    if not Turn.submittedActions[player] then
        Turn.submittedActions[player] = {}
    end

    Turn.submittedActions[player].attack = attackEnergy
end

function shuffleActions()
    local shuffledActions = {}

    for player, action in pairs(Turn.submittedActions) do
        table.insert(shuffledActions, {player = player, action = action})
    end

    for i = 1, #shuffledActions do
        local j = math.random(i, #shuffledActions)
        shuffledActions[i], shuffledActions[j] = shuffledActions[j], shuffledActions[i]
    end

    return shuffledActions
end

function processTurn()

    -- add energy
    for player, state in pairs(Players) do
        local newEnergy = math.floor(math.min(MaxEnergy, state.energy + EnergyPerTurn))
        state.energy = newEnergy
    end

    -- perform moves
    for _, item in pairs(shuffleActions()) do
        if Players[item.player] and item.action.move then
            move({
                From = item.player,
                Tags = {
                    Direction = item.action.move
                },
                Timestamp = Now
            })
        end
    end

    -- perform attacks
    for _, item in pairs(shuffleActions()) do
        if Players[item.player] and item.action.attack then
            attack({
                From = item.player,
                Tags = {
                    AttackEnergy = item.action.attack
                },
                Timestamp = Now
            })
        end
    end

    encodeGameState()

    -- players are listeners since they requested GameState once
    -- send game state to listeners
    sendGameStateToListeners()

    Turn.submittedActions = {}
    Turn.count = Turn.count + 1
    Turn.lastTurn = Now

    -- this is for grid display i guess
    while #LastPlayerAttacks > 20 do
        table.remove(LastPlayerAttacks, 1)
    end

end

function sendGameStateToListeners()
    for listener, _ in pairs(Listeners) do
        sendGameStateToPlayer(listener)
    end
end

function encodeGameState()
    local json = require("json")

    local filteredBalances = {}

    -- filter only playing players
    for player, balance in pairs(Balances) do
        if Players[player] then
            filteredBalances[player] = balance
        end
    end

    GameStateJson = json.encode({
        GameMode = GameMode,
        Players = Players,
        PlayerBalances = filteredBalances,
    })
end

function sendGameStateToPlayer(player)
    Send({
        Target = player,
        Action = "GameState",
        Data = GameStateJson
    })
end


-- Initializes default player state
-- @return Table representing player's initial state
function playerInitState()
    return {
        x = math.random(1, Width),
        y = math.random(1, Height),
        health = 100,
        energy = 0,
        lastTurn = 0
    }
end

-- Main loop cycle
function onTick()

    if GameMode ~= "Playing" then return end  -- Only active during "Playing" state

    local Elapsed = Now - (Turn.lastTurn or 0)

    if Elapsed > WaitTurnLimit or haveAllPlayersSubmittedActions() then
        print("Processing turn...")
        processTurn()
    end    

end

local function isOccupied(x,y) 
  local result = false
  for k,v in pairs(Players) do
    if v.x == x and v.y == y then
        result = true
        return
    end
  end
  return result
end

-- Handles player movement
-- @param msg: Message request sent by player with movement direction and player info
function move(msg)
    local playerToMove = msg.From
    local direction = msg.Tags.Direction

    local directionMap = {
        Up = {x = 0, y = -1}, Down = {x = 0, y = 1},
        Left = {x = -1, y = 0}, Right = {x = 1, y = 0},
        UpRight = {x = 1, y = -1}, UpLeft = {x = -1, y = -1},
        DownRight = {x = 1, y = 1}, DownLeft = {x = -1, y = 1},
    }

    if (direction == "Stay") then
        print("Stayed...")
        print(Players[playerToMove])
        Players[playerToMove].lastTurn = msg.Timestamp
        return
    end

    -- calculate and update new coordinates
    if directionMap[direction] then
        local newX = Players[playerToMove].x + directionMap[direction].x
        local newY = Players[playerToMove].y + directionMap[direction].y

        -- Player cant move to cell already occupied.
        if isOccupied(newX, newY) then
            Send({Target = playerToMove, Action = "Move-Failed", Reason = "Cell Occupied."})
            return 
        end

        -- updates player coordinates while checking for grid boundaries
        Players[playerToMove].x = (newX - 1) % Width + 1
        Players[playerToMove].y = (newY - 1) % Height + 1

        Send({Target = playerToMove, Action="Player-Moved", Data = playerToMove .. " moved to " .. Players[playerToMove].x .. "," .. Players[playerToMove].y .. "."})
    else
        Send({Target = playerToMove, Action = "Move-Failed", Reason = "Invalid direction."})
    end

    print("Moved...")
    print(Players[playerToMove])
    Players[playerToMove].lastTurn = msg.Timestamp
end

-- Handles player attacks
-- @param msg: Message request sent by player with attack info and player state
function attack(msg)
    local player = msg.From
    local attackEnergy = tonumber(msg.Tags.AttackEnergy) < 0 and 0 or tonumber(msg.Tags.AttackEnergy)

    if not Players[player] then
        Send({Target = player, Action = "Attack-Failed", Reason = "Player not found."})
        return
    end

    -- get player coordinates
    local x = Players[player].x
    local y = Players[player].y
    
    -- check if player has enough energy to attack
    if Players[player].energy < attackEnergy then
        ao.send({Target = player, Action = "Attack-Failed", Reason = "Not enough energy."})
        return
    end

    -- update player energy and calculate damage
    Players[player].energy = Players[player].energy - attackEnergy
    local damage = math.floor((math.random() * 2 * attackEnergy) * (1/AverageMaxStrengthHitsToKill))

    -- check if any player is within range and update their status
    for target, state in pairs(Players) do
        if target ~= player and inRange(x, y, state.x, state.y, Range) then
            local newHealth = state.health - damage
            -- Document Current Attacks
            CurrentAttacks = CurrentAttacks + 1
            LastPlayerAttacks[CurrentAttacks] = {
                Player = player,
                Target = target,
                id = CurrentAttacks
            }
            if newHealth <= 0 then
                eliminatePlayer(target, player)
            else
                Players[target].health = newHealth
                Send({Target = target, Action = "Hit", Damage = tostring(damage), Health = tostring(newHealth)})
                Send({Target = player, Action = "Successful-Hit", Recipient = target, Damage = tostring(damage), Health = tostring(newHealth)})
            end
        end
    end
    print("attacked...")
    print(Players[player])
    Players[player].lastTurn = msg.Timestamp
end

-- Helper function to check if a target is within range
-- @param x1, y1: Coordinates of the attacker
-- @param x2, y2: Coordinates of the potential target
-- @param range: Attack range
-- @return Boolean indicating if the target is within range
function inRange(x1, y1, x2, y2, range)
    return x2 >= (x1 - range) and x2 <= (x1 + range) and y2 >= (y1 - range) and y2 <= (y1 + range)
end

-- HANDLERS


-- Handler for player movement
function OnPlayerMove(msg)
    Now = tonumber(msg.Timestamp)
    addPlayerMoveAction(msg.From, msg.Tags.Direction)
    onTick()
end

Handlers.add("PlayerMove",
    Handlers.utils.hasMatchingTag("Action", "PlayerMove"),
    function (msg)
        Now = tonumber(msg.Timestamp)
        local status, err = pcall(OnPlayerMove, msg)
        if not status then
          print(err)
          addLog("OnPlayerMove", err)
        end

    end
)

-- Handler for player attacks
function OnPlayerAttack(msg)
    Now = tonumber(msg.Timestamp)
    addPlayerAttackAction(msg.From, tonumber(msg.Tags.AttackEnergy))
    onTick()
end

Handlers.add("PlayerAttack",
    Handlers.utils.hasMatchingTag("Action", "PlayerAttack"),
    function (msg)
        Now = tonumber(msg.Timestamp)
        local status, err = pcall(OnPlayerAttack, msg)
        if not status then
          print(err)
          addLog("OnPlayerAttack", err)
        end
    end
)


-- Removes a listener from the listeners' list.
-- @param listener: The listener to be removed.
function removeListener(listenerPid)
    Listeners[listenerPid] = nil
end

function addListener(listenerPid)
    Listeners[listenerPid] = true
end

-- Handles the elimination of a player from the game.
-- @param eliminated: The player to be eliminated.
-- @param eliminator: The player causing the elimination.
function eliminatePlayer(eliminated, eliminator)

    Balances[eliminator] = tostring(
        tonumber(Balances[eliminator] or 0) + tonumber(Balances[eliminated] or 0)
    )
    
    Balances[eliminated] = "0"
    Players[eliminated] = nil
    Turn.submittedActions[eliminated] = nil

    Send({
        Target = eliminated,
        Action = "Eliminated",
        Eliminator = eliminator
    })

    removeListener(eliminated)
    
end

function scaleNumber(oldValue)
    local oldMin = 10
    local oldMax = 1000
    local newMin = 1
    local newMax = 100

    local newValue = (((oldValue - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
    return newValue
end


-- HANDLERS: Game state management

-- Handler for cron messages, manages game state transitions.
Handlers.add(
    "Game-State-Timers",
    function(Msg)
        return "continue"
    end,
    function(Msg)
        Now = tonumber(Msg.Timestamp)
        local status, err = pcall(onTick)
        if not status then
          print(err)
          addLog("onTick", err)
        end
    end
)

Handlers.add(
    "Tick",
    Handlers.utils.hasMatchingTag("Action", "Tick"),
    function(Msg)
        Now = tonumber(Msg.Timestamp)
    end
)

-- Handler for player deposits to participate in the next game.
function tableLength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function OnTransfer(Msg)
    local q = tonumber(Msg.Quantity) 
    if tableLength(Players) >= MaximumPlayers then
        Send({
            Target = Msg.From,
            Action = "Game-Full",
            Data = "Game is full."
        })
        Send({
            Target = CRED,
            Action = "Transfer",
            Quantity = tostring(q),
            Recipient = Msg.From
        })
        return
    end

    if not Balances[Msg.Sender] then
        Balances[Msg.Sender] = "0"
    end

    local balance = tonumber(Balances[Msg.Sender])
    Players[Msg.Sender] = playerInitState()
    
    balance = math.floor(balance + q)
    Balances[Msg.Sender] = tostring(balance)

    if balance <= 10 then
        Players[Msg.Sender].health = 1
    elseif balance >= 1000 then
        Players[Msg.Sender].health = 100
    else
        Players[Msg.Sender].health = math.floor(scaleNumber(balance))
    end

    Send({
        Target = Msg.Sender,
        Action = "Payment-Received",
        Data = "You are in the game."
    })

    addListener(Msg.Sender)
    encodeGameState()
    sendGameStateToListeners()
    
end

Handlers.add(
    "Transfer",
    function(Msg)
        return
            Msg.Action == "Credit-Notice" and
            Msg.From == CRED and
            tonumber(Msg.Quantity) >= PaymentQty and "continue"
    end,
    function(Msg)
        Now = tonumber(Msg.Timestamp)
        local status, err = pcall(OnTransfer, Msg)
        if not status then
          print(err)
          addLog("OnTransfer", err)
        end
    end
)

-- Exits the game receives CRED
Handlers.add(
    "Withdraw",
    Handlers.utils.hasMatchingTag("Action", "Withdraw"),
    function(Msg)
        if not Balances[Msg.From] or Balances[Msg.From] == "0" then
            print("No balance to withdraw")
        else
            Send({Target = CRED, Action = "Transfer", Quantity = Balances[Msg.From], Recipient = Msg.From })
            Balances[Msg.From] = "0"
        end

        Players[Msg.From] = nil
        Turn.submittedActions[Msg.From] = nil
        removeListener(Msg.From)

        Send({
            Target = Msg.From,
            Action = "Removed",
            Data = "Removed from Grid"
        })
    end
)

Handlers.add("StopListen",
    Handlers.utils.hasMatchingTag("Action", "StopListen"),
    function(Msg)
        removeListener(Msg.From)
    end
)

-- Retrieves the current game state.
Handlers.add(
    "GetGameState",
    Handlers.utils.hasMatchingTag("Action", "GetGameState"),
    function (Msg)
        if Players[Msg.From] and Msg.Name then
            Players[Msg.From].name = Msg.Name
        end

        addListener(Msg.From)
        if Turn.waitingCount > 0 then

            local timeTillForced = WaitTurnLimit - (Now - Turn.lastTurn)

            Send({
                Target = Msg.From,
                Action = "Waiting",
                Data = "Waiting for " .. tostring(Turn.waitingCount) .. " players to submit actions.",
                Waiting = tostring(Turn.waitingCount),
                Timeout = tostring(timeTillForced)
            })
        end
    end
)

-- Retrieves the current attacks that has been made in the game.
Handlers.add(
    "GetGameAttacksInfo",
    Handlers.utils.hasMatchingTag("Action", "GetGameAttacksInfo"),
    function (Msg)
        local GameAttacksInfo = require("json").encode({
            LastPlayerAttacks = Utils.values(LastPlayerAttacks)
        })
        Send({
            Target = Msg.From,
            Action = "GameAttacksInfo",
            Data = GameAttacksInfo
        })
    end
)