-- compatability with any Lua environment
Handlers = Handlers or {
  utils = { hasMatchingTag = function(tag, val) end },
  add = function(name, check, exec) end,
  remove = function(name) end
}
ao = ao or { send = function(obj) end, id = "unknown" }
undefined = undefined or "undefined"

-- default imports
local json = require('json')
local bint = require('.bint')(256)

-- helpers
local utils = {
  add = function (a,b)
    return tostring(bint(a) + bint(b))
  end,
  subtract = function (a,b)
    return tostring(bint(a) - bint(b))
  end,
  toBalanceValue = function (a)
    return tostring(bint(a))
  end,
  toNumber = function (a)
    return tonumber(a)
  end
}

Denomination = Denomination or 3 -- match CRED

-- Minting
CRED = "Sa0iBLPNyJQrwpTTG-tWLQU-1QeUAJA73DdxGGiKoJc" -- $CRED
MaxMint = MaxMint or (100000 * 10 ^ Denomination)
Minted = Minted or 0

-- Token
Balances = Balances or { [ao.id] = utils.toBalanceValue(0) }
TotalSupply = TotalSupply or utils.toBalanceValue(0)
Name = Name or 'GROG Coin'
Ticker = Ticker or 'GROG'
Logo = 'vwPg7nLQ2MgZbhdeKyV2FATXdQLwVzVH2pgffKZQOB4'

Handlers.add('info', Handlers.utils.hasMatchingTag('Action', 'Info'), function(msg)
  ao.send({
    Target = msg.From,
    Name = Name,
    Ticker = Ticker,
    Logo = Logo,
    Denomination = tostring(Denomination)
  })
end)


Handlers.add('balance', Handlers.utils.hasMatchingTag('Action', 'Balance'), function(msg)
  local bal = '0'

  -- If not Recipient is provided, then return the Senders balance
  if (msg.Tags.Recipient and Balances[msg.Tags.Recipient]) then
    bal = Balances[msg.Tags.Recipient]
  elseif msg.Tags.Target and Balances[msg.Tags.Target] then
    bal = Balances[msg.Tags.Target]
  elseif Balances[msg.From] then
    bal = Balances[msg.From]
  end

  ao.send({
    Target = msg.From,
    Balance = bal,
    Ticker = Ticker,
    Account = msg.Tags.Recipient or msg.From,
    Data = bal
  })
end)

Handlers.add('balances', Handlers.utils.hasMatchingTag('Action', 'Balances'),
  function(msg) ao.send({ Target = msg.From, Data = json.encode(Balances) }) end)

Handlers.add('transfer', Handlers.utils.hasMatchingTag('Action', 'Transfer'), function(msg)
  assert(type(msg.Recipient) == 'string', 'Recipient is required!')
  assert(type(msg.Quantity) == 'string', 'Quantity is required!')
  assert(bint.__lt(0, bint(msg.Quantity)), 'Quantity must be greater than 0')

  if not Balances[msg.From] then Balances[msg.From] = "0" end
  if not Balances[msg.Recipient] then Balances[msg.Recipient] = "0" end

  if bint(msg.Quantity) <= bint(Balances[msg.From]) then
    Balances[msg.From] = utils.subtract(Balances[msg.From], msg.Quantity)
    Balances[msg.Recipient] = utils.add(Balances[msg.Recipient], msg.Quantity)

    if not msg.Cast then
      -- Debit-Notice message template, that is sent to the Sender of the transfer
      local debitNotice = {
        Target = msg.From,
        Action = 'Debit-Notice',
        Recipient = msg.Recipient,
        Quantity = msg.Quantity,
        Data = Colors.gray ..
            "You transferred " ..
            Colors.blue .. msg.Quantity .. Colors.gray .. " to " .. Colors.green .. msg.Recipient .. Colors.reset
      }
      -- Credit-Notice message template, that is sent to the Recipient of the transfer
      local creditNotice = {
        Target = msg.Recipient,
        Action = 'Credit-Notice',
        Sender = msg.From,
        Quantity = msg.Quantity,
        Data = Colors.gray ..
            "You received " ..
            Colors.blue .. msg.Quantity .. Colors.gray .. " from " .. Colors.green .. msg.From .. Colors.reset
      }

      -- Add forwarded tags to the credit and debit notice messages
      for tagName, tagValue in pairs(msg) do
        -- Tags beginning with "X-" are forwarded
        if string.sub(tagName, 1, 2) == "X-" then
          debitNotice[tagName] = tagValue
          creditNotice[tagName] = tagValue
        end
      end

      -- Send Debit-Notice and Credit-Notice
      ao.send(debitNotice)
      ao.send(creditNotice)
    end
  else
    ao.send({
      Target = msg.From,
      Action = 'Transfer-Error',
      ['Message-Id'] = msg.Id,
      Error = 'Insufficient Balance!'
    })
  end
end)

--[[
    Mint
   ]]
--

function tokenMint(pid, quantity)
  assert(type(quantity) == 'string', 'Quantity is required!')
  assert(bint(0) < bint(quantity), 'Quantity must be greater than zero!')

  if not Balances[ao.id] then Balances[ao.id] = "0" end

  -- check MaxMint

  Balances[pid] = utils.add(Balances[pid], quantity)
  TotalSupply = utils.add(TotalSupply, quantity)
end


Handlers.add('mint', Handlers.utils.hasMatchingTag('Action', 'Mint'), function(msg)

  if msg.From == ao.id then
    -- Add tokens to the token pool, according to Quantity

    tokenMint(msg.From, msg.Quantity)

    ao.send({
      Target = msg.From,
      Data = Colors.gray .. "Successfully minted " .. Colors.blue .. msg.Quantity .. Colors.reset
    })
  else
    ao.send({
      Target = msg.From,
      Action = 'Mint-Error',
      ['Message-Id'] = msg.Id,
      Error = 'Only the Process Id can mint new ' .. Ticker .. ' tokens!'
    })
  end
end)

--[[
     Total Supply
   ]]
--
Handlers.add('totalSupply', Handlers.utils.hasMatchingTag('Action', 'Total-Supply'), function(msg)
  assert(msg.From ~= ao.id, 'Cannot call Total-Supply from the same process!')

  ao.send({
    Target = msg.From,
    Action = 'Total-Supply',
    Data = TotalSupply,
    Ticker = Ticker
  })
end)

--[[
 Burn
]] --
-- same function as in handler above
function tokenBurn(pid, quantity)
  assert(type(quantity) == 'string', 'Quantity is required!')
  assert(bint(quantity) <= bint(Balances[pid]), 'Quantity must be less than or equal to the current balance!')

  Balances[pid] = utils.subtract(Balances[pid], quantity)
  TotalSupply = utils.subtract(TotalSupply, quantity)

end

Handlers.add('burn', Handlers.utils.hasMatchingTag('Action', 'Burn'), function(msg)

  tokenBurn(msg.From, msg.Quantity)

  ao.send({
    Target = msg.From,
    Data = Colors.gray .. "Successfully burned " .. Colors.blue .. msg.Quantity .. Colors.reset
  })

end)


-- Minting from CRED

function sendMoneyBack(msg, reason)
  
  local requestedAmount = tonumber(msg.Quantity)

  ao.send({
    Target = CRED,
    Action = "Transfer",
    Recipient = msg.Sender,
    Quantity = tostring(requestedAmount),
    Data = reason
  })

  ao.send({Target = msg.Sender, Data = reason})

end


function mintFromCred(m)

  local amount = tonumber(m.Quantity)

  if (Minted + amount) > MaxMint then
    sendMoneyBack(m, "MAX_CAP: Max cap reached - Refund")
    return
  end

  assert(type(Balances) == "table", "Balances not found!")

  Balances[m.Sender] = utils.add(Balances[m.Sender] or "0", tostring(amount))
  Minted = Minted + amount

  -- update TotalSupply
  TotalSupply = utils.add(TotalSupply, tostring(amount))

  ao.send({Target = m.Sender, Data = "MINTED: Successfully Minted " .. amount})

end


Handlers.prepend(
  "Mint",
  function(m)
    return m.Action == "Credit-Notice" and m.From == CRED
  end,
  function (m)
    -- safe call
    local status, err = pcall(mintFromCred, m)
    if not status then
      UI.log("MintFromCred", err)
    end
  end
)
