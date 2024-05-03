
-- Library (blueprint)

UI_APP = {
  PAGES = {
    path = '/',
    html = '<h1>Hello World!</h1>'
  },
  InitState = function (pid) return {} end
}

UI_STATE = {}

UI = {

  now = 0,
  logs = {},

  log = function (msg, text)
    UI.logs[msg] = UI.logs[msg] or {}
    table.insert(UI.logs[msg], text)
  end,

  set = function (pid, state)
    if not UI_STATE[pid] then
      if UI_APP.InitState then
        UI_STATE[pid] = UI_APP.InitState(pid)
        return
      else
        UI_STATE[pid] = {}
        return
      end
    end

    for k, v in pairs(state) do
      UI_STATE[pid][k] = v
    end
  end,

  page = function (pid, page)
  
    page = page or '/'
    local html = UI_APP.PAGES[page]

    if not html then
      UI.log("UI.go", "page not found: " .. page)
      return '<html><h1>404</h1></html>'
    end
    
    for k, v in pairs(UI_STATE[pid] or {}) do
      html = html:gsub("{{" .. k .. "}}", '"' .. v .. '"')
    end

    UI.set(pid, { page = page })

    return html
  end,

  state = function (pid)
    local json = require 'json'
    return json.encode(UI_STATE[pid])
  end,

  onGetPage = function (msg)
    local pid = msg.From
    local page = msg.Tags.Path or '/'
    print (UI.page(pid, page))
  end,

  onRun = function (msg)
    local json = require 'json'
 
    local pid = msg.From
    local command = msg.Tags.Data
    local args = json.decode(msg.Tags.Args)
    args.pid = pid

    local html = UI_APP.PAGES[ UI_STATE[pid].path or '/' ]
    if not html then
      UI.log("UI.onRun", "page not found")
      print ('<html><h1>404</h1></html>')
      return
    end
 
    -- check that current page contains 'ui-run="${command}('
    local contains = html:find('ui-run="' .. command .. '(')
    if not contains then
      UI.log("UI.onRun", "command not found")
      print ('<html><h1>404 - command not found in page</h1></html>')
      return
    end

    local fn = _G[command]
    if not fn then
      UI.log("UI.onRun", "function not found")
      print ('<html><h1>404 - function not found in code</h1></html>')
      return
    end

    local status, result = pcall(fn, args)
    if not status then
      UI.log("UI.onRun", result)
      print ('<html><h1>500 - command run failed</h1></html>')
      return
    end

    print (result)

  end
 
}

Handlers.add("UI_RUN",
  Handlers.utils.hasMatchingTag("Action", "UI_RUN"),
  function (msg)
    UI.now = tonumber(msg.Timestamp)

    local status, err = pcall(UI.onRun, msg)
    if not status then
      UI.log("UI_RUN", err)
      print ('<html><h1>500 - run failed</h1></html>')
    end
  end
)

Handlers.add("UI_GET_PAGE",
  Handlers.utils.hasMatchingTag("Action", "UI_GET_PAGE"),
  function (msg)
    UI.now = tonumber(msg.Timestamp)

    local status, err = pcall(UI.onGetPage, msg)
    if not status then
      UI.log("UI_GET_PAGE", err)
      print ('<html><h1>500</h1></html>')
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
        <ui-input ui-id="name" ui-type="String" />
        <ui-button label="Login" ui-valid="name" ui-run="cmdLogin($name)" />
      ]]
    },
    {
      path = '/home',
      html = [[
        <h1>Welcome, {{name}}!</h1>
        <p>What would you like to do?</p>
        <ui-button label="Logout" ui-action="cmdLogout($pid)" />
      ]]
    }
  },

  InitState = function (pid)
    return {
      name = ""
    }
  end,
}

function cmdLogin(args)
  UI.set(args.pid, { name = args.name })
  return UI.page(args.pid, "/home") .. UI.state(args.pid)
end


function cmdLogout(args)
  UI.set(args.pid, { name = "" })
  return UI.page(args.pid, "/")
end

