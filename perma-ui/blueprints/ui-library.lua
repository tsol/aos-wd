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

UI_APP = UI_APP or {
  PAGES = {
    {
      path = '/',
      html = '<h1>Hello World!</h1>'
    },
  },
  InitState = function(pid) return {} end
}

UI_STATE = UI_STATE or {}

UI = {

  developerPid = nil,

  now = 0,
  logs = {},
  currentPid = nil,
  redirectCount = 0,

  sessionEnd = function()
    UI.currentPid = UI.developerPid
    UI.redirectCount = 0
  end,

  log = function(msg, text)
    UI.logs[msg] = UI.logs[msg] or {}
    table.insert(UI.logs[msg], text)
  end,

  set = function(state, pid)
    pid = pid or UI.currentPid

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

  currentPath = function()
    local pid = UI.currentPid
    if not pid then
      UI.log("UI.currentPath", "pid not specified")
      return
    end

    return UI_STATE[pid].path
  end,

  currentPage = function(forPid)
    local pid = forPid or UI.currentPid
    if not pid then
      UI.log("UI.currentPage", "pid not specified")
      return
    end

    return UI.findPage(UI_STATE[pid].path)
  end,

  findPage = function(path)
    for _, page in ipairs(UI_APP.PAGES) do
      if page.path == path then
        return page
      end
    end
  end,

  renderPage = function(page, pid)
    local html = page and page.html
    local layoutFn = page.layout
    if layoutFn then
      html = layoutFn(page, html, pid)
    end
    return html
  end,

  fullResponse = function(path, pid)
    local resPid = pid or UI.currentPid

    local resPageHtml = UI.page({ path = path, pid = resPid })
    local newPage = UI.findPage(UI_STATE[resPid].path)

    return resPageHtml .. UI.pageState(newPage) .. UI.state(pid)
  end,

  page = function(args)
    local path = args.path or '/'
    local pid = args.pid or UI.currentPid
    local force = args.force

    if not pid then
      UI.log("UI.page", "pid not specified")
      return UI.renderError(404, "pid not specified")
    end

    local page = UI.findPage(path)
    if not page then
      UI.log("UI.page", "page not found: " .. path)
      return UI.renderError(404, "page not found")
    end

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

    local html = UI.renderPage(page, pid)
    if not html then
      UI.log("UI.page", "page not found: " .. path)
      return UI.renderError(404, "page not found")
    end

    UI.set({ path = path })

    for k, v in pairs(UI_STATE[pid] or {}) do
      html = html:gsub("{~" .. k .. "~}", v)
    end

    return UI.renderHtml(html, force)
  end,

  state = function(forPid)
    local pid = forPid or UI.currentPid
    local res = UI_STATE[pid]

    if not pid then
      UI.log("UI.state", "pid not specified: ")
      res = { error = "pid not specified" }
    end

    res['_type'] = 'UI_STATE'
    res['pid'] = pid

    local json = require 'json'
    return json.encode(res)
  end,

  pageState = function(page)
    if not page or not page.path or not page.state then
      return ''
    end

    local res = { [page.path] = page.state }
    res['_type'] = 'UI_PAGE_STATE'

    local json = require 'json'
    return json.encode(res)
  end,

  sendPageState = function(page, filterFn)
    local pstate = UI.pageState(page)
    if not pstate then return end

    for pid, ustate in pairs(UI_STATE) do
      local filterPass = not filterFn or (filterFn and filterFn(pid, ustate))
      if ustate.path == page.path and filterPass then
        ao.send({ Target = pid, Action = "UI_RESPONSE", Data = pstate .. UI.state(pid) })
      end
    end

    return true
  end,

  renderHtml = function(html, force)
    local res = '<html>'

    local pid = UI.currentPid
    local noonce = ''

    if pid then
      noonce = UI_STATE[pid]._noonce or ''
    end

    if force then
      noonce = 'force'
    end

    res = res .. '<!--noonce:' .. noonce .. '-->'
    res = res .. html .. '</html>'
    return res
  end,

  renderError = function(code, msg)
    return UI.renderHtml('<h1>' .. code .. '</h1><p>' .. msg .. '</p>')
  end,

  forceSendPageToPid = function(pid, path)

    if not pid then
      UI.log("UI.forceSendPage", "pid not specified")
      return
    end

    if not path then
      UI.log("UI.forceSendPage", "path not specified")
      return
    end

    local page = UI.findPage(path)
    if not page then
      UI.log("UI.forceSendPage", "page not found: " .. path)
      return
    end

    ao.send({ Target = pid, Action = "UI_RESPONSE",
      Data =
        UI.page({ path = path, pid = pid, force = true }) ..
        UI.pageState(page) ..
        UI.state(pid)
    })
  end,

  sessionStart = function(msg)
    UI.now = tonumber(msg.Timestamp)

    local pid = msg.From
    UI.currentPid = pid

    if pid and not UI_STATE[pid] then
      if UI_APP.InitState then
        UI_STATE[pid] = UI_APP.InitState(pid)
        UI_STATE[pid].pid = pid
      else
        UI_STATE[pid] = { pid = pid }
      end
    end

    local noonce = msg.Tags.Noonce
    if pid and noonce then
      UI_STATE[pid] = UI_STATE[pid] or {}
      UI_STATE[pid]._noonce = noonce
    end
  end,

  reply = function(data)
    ao.send({ Target = UI.currentPid, Action = "UI_RESPONSE", Data = data })
  end,

  -- Handlers --------------------
  onGetPage = function(msg)
    UI.sessionStart(msg)
    local path = msg.Tags.Path or '/'

    local resPage = UI.page({ path = path })
    local resPageState = UI.pageState(UI.currentPage())

    UI.reply(
      resPage ..
      resPageState ..
      UI.state()
    )

    UI.sessionEnd()
  end,

  onRun = function(msg)
    UI.sessionStart(msg)
    local pid = UI.currentPid

    if not pid then
      UI.log("UI.onRun", "pid not specified")
      UI.reply(UI.renderError(404, "pid not specified"))
      UI.sessionEnd()
      return
    end

    local command = msg.Data

    if not command then
      UI.log("UI.onRun", "command not specified")
      UI.reply(UI.renderError(404, "command not specified"))
      UI.sessionEnd()
      return
    end

    local json = require 'json'
    local args = json.decode(msg.Tags.Args)

    local page = UI.findPage(UI_STATE[pid].path or '/')
    local html = UI.renderPage(page, pid)
    if not html then
      UI.log("UI.onRun", "page not found")
      UI.reply(UI.renderError(404, "page not found"))
      UI.sessionEnd()
      return
    end

    local contains = html:find('ui%-run="' .. command) ~= nil

    if not contains then
      UI.log("UI.onRun", "command not found " .. command .. " in page " .. html)
      UI.reply(UI.renderError(404, "command not found in page"))
      UI.sessionEnd()
      return
    end

    local fn = _G[command]
    if command == "UI.page" then fn = UI.page end
    if command == "UI.set" then fn = UI.set end

    if not fn then
      UI.log("UI.onRun", "function not found: " .. command)
      UI.reply(UI.renderError(404, "function not found in code: " .. command))
      UI.sessionEnd()
      return
    end

    local status, result = pcall(fn, args)
    if not status then
      UI.log("UI.onRun", result)
      UI.reply(UI.renderError(500, result))
      UI.sessionEnd()
      return
    end

    UI.reply(result)
    UI.sessionEnd()
  end,


}

UI.sessionEnd()

Handlers.add("UIRun",
  Handlers.utils.hasMatchingTag("Action", "UIRun"),
  function(msg)
    local status, err = pcall(UI.onRun, msg)
    if not status then
      UI.log("UIRun", err)
      UI.reply(UI.renderError(500, err))
    end
  end
)

Handlers.add("UIGetPage",
  Handlers.utils.hasMatchingTag("Action", "UIGetPage"),
  function(msg)
    local status, err = pcall(UI.onGetPage, msg)
    if not status then
      UI.log("UIGetPage", err)
      UI.reply(UI.renderError(500, err))
    end
  end
)
