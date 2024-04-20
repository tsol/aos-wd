# AOS Widget Desktop

### AOS-WD v39.0.0 - almost the best lubricant for your AOS dev:

With this tool for example you can setup your own Arena and several bots in a few clicks,
and then start advancing your bots or your game with a help of a built-in IDE.

Create fast to execute snippets, load blueprints, update Handlers by selecting only
the portion of code you want to update, and much more.

Also you can develop your own widgets to make User Interface for any game or service you come up with.

## Features

- work with several AOS processes simultaneously
- create and run processes with a single click
- built-in IDE with syntax highlighting and execution / partial execution
- built-in console with syntax highlighting
- expandable with custom widgets
- load blueprints right from aos or this project github in IDE

## Available Widgets

- BotGame (in progress) - graphical GRID Arena BOT client. A good starting point for your bot development.
- Arena (in progress) - contains snippet for demo arena
- Console - console for the current process
- IDE - code editor with syntax highlighting


## Two bots and Arena in a few clicks

### New own Arena

1. Create a new arena process. Type in 'arena' and press Create.
2. Press Add widget and add Arena widget to desktop.
3. Press 'Load game' snippet (this will load arena.lua into process)
4. Add standart token to the arena process:
 - Add widget IDE to desktop
 - In IDE widget press Github icon
 - Select 'AOS permaweb' tab and click 'token.lua'
 - In IDE press Play button

Ok, done now you have process with arena and token.

### Adding a bot

1. Create new process. Type in 'bot1' and press Create.
2. Press Add widget and add BotGame widget to desktop.
3. Press 'Init BOT' snippet
 - right after that snipped menu will pop up, because gamePid template variable
 (which is referenced in botgame.lua) is not defined yet.
4. Press on arrow down icon popup where you have been creating new processes.
 - Select Arena from the list, and copy its PID by pressing on it.
5. Paste the PID into the gamePid field in the snippet 'Init BOT' and press Apply.
6. Run the snipped

This time all must go smoothly, evaluated botgame.lua template will run and create the bot.

7. Press 'Register' snippet - this should register your bot in the arena.
8. Press 'Request Tokens' snippet - this should request tokens from the arena.
9. Press 'BET' snippet - this should make a bet and register for the next round.
10. Press 'GET STATE' widget to get current game state from arena.

The game won't start with just one player, so you need to repeat the steps for the second bot.
Then when all the bots are registered, the game will start after next timeout.

## Widget architecture and workflow

Each widget is defined by a typescript file and a vue file. Typescript file contains the
schema of your widget state (if any required), custom parsers (if needed), default widgets code. Vue file contains the view for the widget. If the view file is not needed, then only snippets will
appear when you enable your widget.

The main parser process analyzes all the incomming messages from AOS network,
and parses the input using custom widget parsers or the state schema, which is conviniently
required to be defined in ZOD format. Once successfull parse is done, the widget state is updated.

NOTE: There is a useProcess() composable available for your widget view, but when it comes to
state, please use state from properties, not from the composable. The reason for this is
that state in the composable is the recent current state, while the state in the properties
can be from the 'state history browse' feature (not implemented yet).


## Setup

Make sure to install the dependencies:

```bash
# npm
npm install
```

## Development Server

Start the development server on `http://localhost:3000`:

```bash
# npm
npm run dev
```

## Screenshot

![image](https://github.com/tsol/aos-wd/assets/1220139/fe73990a-0969-46d6-b596-f9947863704a)
![image](https://github.com/tsol/aos-wd/assets/1220139/84c9ae8f-5f42-4b4e-801e-28d63d8eec62)


## TODO

- bug: About menu item is not working
- bug: Resize console when drawer is opened/closed (or make it laways overlay?)

x. Lua interpreter in IDE

x. Widget Layout change column width, alter widget height.
 - also remove empty cols

x. Snippet editor context menu: 'Send (and execute) to other processes'. 

x. Copy PID by click from process name (also context menu)

x. Widget context menu: 'Send layout to other processes'

x. Cron poll (snippet option to schedule interval)

x. - make active links to connect to process by Ctrl+click

x. Time for each line of console


---

x. IDE widget - store to github

x. Layout for snippet buttons ( programable or template or draggable ?)

x. aos fetch/request montitor and stats in header (cuXX statistics on hover)

x. Widget History feature

x. title for snippets? with templates?



