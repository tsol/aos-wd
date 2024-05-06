-- TSOL common

-- compatability with any Lua environment
Handlers = Handlers or {
  utils = { hasMatchingTag = function(tag, val) end },
  add = function(name, check, exec) end,
  remove = function(name) end
}
ao = ao or { send = function(obj) end, id = "unknown" }
undefined = undefined or "undefined"


-- UI Library (blueprint)

UI_APP = {
  PAGES = {
    {
      path = '/',
      html = '<h1>Hello World!</h1>'
    },
  },
  InitState = function (pid) return {} end
}

UI_STATE = {}

UI = {

  now = 0,
  logs = {},
  currentPid = nil,
  redirectCount = 0,

  sessionEnd = function ()
    -- UI.currentPid = nil -- production
    UI.currentPid = ao.id -- dev
    UI.redirectCount = 0
  end,

  log = function (msg, text)
    UI.logs[msg] = UI.logs[msg] or {}
    table.insert(UI.logs[msg], text)
  end,

  set = function (state)

    local pid = UI.currentPid

    if not pid then
      UI.log("UI.set", "pid not specified")
      return
    end

    if not UI_STATE[pid] then
      if UI_APP.InitState then
        UI_STATE[pid] = UI_APP.InitState(pid)
      else
        UI_STATE[pid] = {}
      end
    end

    for k, v in pairs(state) do
      if k ~= "pid" then 
      UI_STATE[pid][k] = v
      end
    end

    return UI.state()
  end,

  findPage = function (path)
    for _, page in ipairs(UI_APP.PAGES) do
      if page.path == path then
        return page
      end
    end
  end,

  page = function (args)
  
    local path = args.path or '/'
    local pid = UI.currentPid

    if not pid then
      UI.log("UI.page", "pid not specified")
      return UI.renderError(404, "pid not specified")
    end

  
    local page = UI.findPage(path)
    if page.guard then
      local newPath = page.guard(pid)

      if newPath and newPath ~= path then
        UI.redirectCount = UI.redirectCount + 1
        if UI.redirectCount > 10 then
          UI.log("UI.page", "redirect loop detected")
          return UI.renderError(500, "redirect loop detected")
        end
        return UI.page({ path = newPath })
      end

    end

    local html = page and page.html

    if not html then
      UI.log("UI.page", "page not found: " .. path)
      return UI.renderError(404, "page not found")
    end
    
    UI.set({ path = path })

    for k, v in pairs(UI_STATE[pid] or {}) do
      html = html:gsub("{~" .. k .. "~}", v)
    end

    return UI.renderHtml(html)
  end,

  state = function ()
    local pid = UI.currentPid
    local res = UI_STATE[pid]
    if not pid then
      UI.log("UI.state", "pid not specified")
      res = { error = "pid not specified" }
    end
    
    res['_type'] = 'UI_STATE'

    local json = require 'json'
    return json.encode(res)
  end,

  renderHtml = function (html)
    local res = '<html>'

    local pid = UI.currentPid
    local noonce = ''
    if pid then
      noonce = UI_STATE[pid]._noonce or ''
    end

    res = res .. '<!--noonce:' .. noonce .. '-->'
    res = res .. html .. '</html>'
    return res

  end,

  renderError = function (code, msg)
    return UI.renderHtml('<h1>' .. code .. '</h1><p>' .. msg .. '</p>')
  end,

  sessionStart = function (msg)

    UI.now = tonumber(msg.Timestamp)

    local pid = msg.From
    UI.currentPid = pid

    if pid and not UI_STATE[pid] then
      if UI_APP.InitState then
        UI_STATE[pid] = UI_APP.InitState(pid)
      else
        UI_STATE[pid] = {}
      end
    end

    local noonce = msg.Tags.Noonce
    if pid and noonce then
      UI_STATE[pid] = UI_STATE[pid] or {}
      UI_STATE[pid]._noonce = noonce
    end

  end,

  -- Handlers --------------------
  onGetPage = function (msg)
    UI.sessionStart(msg)
    local path = msg.Tags.Path or '/'
    print (UI.page({ path = path }))
    UI.sessionEnd()
  end,

  onRun = function (msg)

    UI.sessionStart(msg)
    local pid = UI.currentPid

    if not pid then
      UI.log("UI.onRun", "pid not specified")
      print (UI.renderError(404, "pid not specified"))
      UI.sessionEnd()
      return
    end

    local command = msg.Data

    if not command then
      UI.log("UI.onRun", "command not specified")
      print (UI.renderError(404, "command not specified"))
      UI.sessionEnd()
      return
    end

    local json = require 'json'
    local args = json.decode(msg.Tags.Args)

    local page = UI.findPage( UI_STATE[pid].path or '/' )
    local html = page and page.html
    if not html then
      UI.log("UI.onRun", "page not found")
      print (UI.renderError(404, "page not found"))
      UI.sessionEnd()
      return
    end
 
    local contains = html:find('ui%-run="' .. command .. '%(') ~= nil

    if not contains then
      UI.log("UI.onRun", "command not found " .. command .. " in page " .. html )
      print (UI.renderError(404, "command not found in page"))
      UI.sessionEnd()
      return
    end

    local fn = _G[command]
    if command == "UI.page" then fn = UI.page end
    if command == "UI.set" then fn = UI.set end

    if not fn then
      UI.log("UI.onRun", "function not found")
      print (UI.renderError(404, "function not found in code"))
      UI.sessionEnd()
      return
    end

    local status, result = pcall(fn, args)
    if not status then
      UI.log("UI.onRun", result)
      print (UI.renderError(500, result))
      UI.sessionEnd()
      return
    end

    print (result)
    UI.sessionEnd()
  end,

 
}

UI.sessionEnd()

Handlers.add("UIRun",
  Handlers.utils.hasMatchingTag("Action", "UIRun"),
  function (msg)
    local status, err = pcall(UI.onRun, msg)
    if not status then
      UI.log("UIRun", err)
      print (UI.renderError(500, err))
    end
  end
)

Handlers.add("UIGetPage",
  Handlers.utils.hasMatchingTag("Action", "UIGetPage"),
  function (msg)
    local status, err = pcall(UI.onGetPage, msg)
    if not status then
      UI.log("UIGetPage", err)
      print (UI.renderError(500, err))
    end
  end
)


-- Code

UI_APP = {

  PAGES = {
    {
      path = '/',
      html = [[
        <h1>UI Example</h1>
        <p>Enter your name:</p>
        <ui-input ui-id="name" ui-type="String" ui-required label="Your name" />
        <ui-input
          ui-id="fruit"
          ui-type="Select"
          ui-required
          label="Your fruit"
          :items="['Apple', 'Banana', 'Cherry', 'Mango']"
        />
        <ui-button ui-valid="name, fruit" ui-run="cmdLogin({ name = $name, fruit = $fruit })">Login</ui-button>
      ]]
    },
    {
      path = '/home',
      html = [[
        <h1>Welcome, {~name~}!</h1>
        <p>What would you like to do with your {~fruit~}?</p>
        <ui-button ui-run="cmdLogout()">Logout</ui-button>
        <ui-button ui-run="UI.page({ path = '/secret' })">Go to Secret Place</ui-button>
      ]]
    },
    {
      path = '/secret',
      guard = function (pid)
        if not UI_STATE[pid] or UI_STATE[pid].name == "" then
          return "/"
        end
        return "/secret"
      end,
      html = [[
        <h1>It is a secret place!, {~name~}!</h1>
        <p>Now you can finally eat your {~fruit~}!</p>
        <ui-button ui-run="UI.page({ path = '/home' })">Go back</ui-button>
        <ui-button ui-run="cmdLogout()">Logout</ui-button>
      ]]
    }
  },

  InitState = function (pid)
    return {
      name = "",
      fruit = ""
    }
  end,
}

function cmdLogin(args)
  UI.set({ name = args.name, fruit = args.fruit }) -- or just UI.set(args)
  
  return
    UI.page({ path = "/home" }) ..
    UI.state()
end


function cmdLogout(args)
  UI.set({ name = "" })
  return UI.page({ path = "/" })
end

