

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
        <h1>It is a secret place, {~name~}!</h1>
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

