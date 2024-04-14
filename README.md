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

Welcome text
Select current tab after first process creation

x. title for snippets? with templates?

4. IDE widget
 - store to github

7. Layout for snippet buttons ( programable or template or draggable ?)

2. Cron poll

3. Input process v-combobox when variable ends with PID

5. aos fetch/request montitor and stats in header


2. Substitute process ids with known names (even if with dots)
 - make active links to connect to process by Ctrl+click
 
6. Manual BOT
 - faster state display
 - by buttons
 - by directions
 
8. Forms 
 - as automatically parsed from template?

9. Widget History feature

10. Time for each line of console

11. change cols width and widget height

