
GUI_MAIN = {

  LAYOUT = [[
    . . . . . . . . . .
    . . . w w w w . . .
    . . . . . . . . . .
    . . . n n . b . . .
    . . . . . . . . . .
  ]],

  w = { html = '<h3>Hello</h3>' },
  n = { input = 'string', submits = 'b', label = 'Your name', col = 3 },
  b = { button = 'rect', click = 'cmdLogin', label = 'Login', icon = 'mdi-account' }

}

GUI_PAGE2 = {

  LAYOUT = [[ hello info ]],

  hello = { isHtml = '<h3>Hello ${name}!</h3>' },
  info = { isHtml = 'Your pid is ${pid}.' }

}

GUI_STATE = {}


function onRequest(msg)
  local pid = msg.From
  if not msg then return end
  if not GUI_STATE[pid] then
    GUI_STATE[pid] = {}
  end
end

function cmdLogin(props)
  local pid = props.pid
  local name = props.n

  print ("LoggedIn: " .. pid .. " as " .. name)
end

FRAME = {




}