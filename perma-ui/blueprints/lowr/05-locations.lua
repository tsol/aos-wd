-- Hall of Fame -----------------------------------------------------------

function roomLayoutHallOfFame(page, origHtml, forPid)
  local pid = UI.currentPid

  -- table of top 10 players by kills
  -- get pid from mem, then join with UI_STATE to get name, level weapon and armor
  local topPlayers = {}

  for pid, mem in pairs(MEM) do
    local player = UI_STATE[pid]
    if player then
      table.insert(topPlayers, {
        name = player.name,
        level = player.level,
        weapon = player.weapon.name,
        armor = player.armor.name,
        kills = mem.kills,
      })
    end
  end

  -- sort by kills
  table.sort(topPlayers, function(a, b) return a.kills > b.kills end)

  -- limit to 10
  topPlayers = { table.unpack(topPlayers, 1, 10) }

  -- render html table
  local table = [[
    <table>
      <tr>
        <th class="px-2">Name</th>
        <th class="px-2">Level</th>
        <th class="px-2">Weapon</th>
        <th class="px-2">Armor</th>
        <th class="px-2">Kills</th>
      </tr>
  ]]

  for _, player in ipairs(topPlayers) do
    table = table .. '<tr>'
    table = table .. string.format('<td class="px-2">%s</td>', player.name)
    table = table .. string.format('<td class="px-2">%d</td>', player.level)
    table = table .. string.format('<td class="px-2">%s</td>', player.weapon)
    table = table .. string.format('<td class="px-2">%s</td>', player.armor)
    table = table .. string.format('<td class="px-2">%d</td>', player.kills)
    table = table .. '</tr>'
  end

  table = table .. '</table>'

  local html = string.format([[
    <div>
      You enter the Hall of Fame. The walls are covered with names of the best of the best.
    </div>
    <div class="mt-4">
      %s
    </div>
  ]], table)

  page.customNavigation = [[
    <div class="d-flex">
    <ui-button ui-run="cmdGo({ dir = 'n' })">Leave</ui-button>
    </div>
  ]]

  return roomLayout(page, html, pid)
end





-- Fountain ---------------------------------------------------------------

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


--- Hospital ---------------------------------------------------------------

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


-- Shops -----------------------------------------------------------------

function cmdBuyItem(args)
  if isPlayerDead() then return deadPlayerRedirect() end

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
  if isPlayerDead() then return deadPlayerRedirect() end

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



-- Placement

addPlace('Central Square', '/hospital', 'Hospital', Terrain.hospital, roomLayoutHospital, {
  terrain = 'hospital',
  breadcrumb = true,
  maxMonsters = 1,
})

addPlace('Central Square', '/weapon-shop', 'Weapon Shop', ShopItemTypes.weapon.icon, roomLayoutWeaponShop, {
  terrain = 'weapons',
})

addPlace('Central Square', '/armor-shop', 'Armor Shop', ShopItemTypes.armor.icon, roomLayoutArmorShop, {
  terrain = 'armor',
})

addPlace('Historic District', '/hall-of-fame', 'Hall of Fame', Icons.Trophy, roomLayoutHallOfFame, {
  terrain = 'hall-of-fame',
})

addPlace('Central Square', '/fountain', 'Fountain', Houses.Fountain, roomLayoutFountain, {
  terrain = 'fountain',
})