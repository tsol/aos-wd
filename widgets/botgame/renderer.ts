import p5 from "p5";
import { shortenCutMiddle } from "~/lib/utils";
import type { State } from '../botgame';

export function Renderer() {
  let p5Instance: p5 | null = null;

  let canvas: HTMLDivElement | null = null;
  let myPid: string | null = null;
  let state: State | null = null;

  function redraw(_state: State) {
    state = _state;
    if (p5Instance) {
      p5Instance.redraw();
    }
  }

  function init(_canvas: HTMLDivElement, _myPid: string) {
    canvas = _canvas;
    myPid = _myPid;

    if (p5Instance) {
      p5Instance.remove();
    }

    p5Instance = new p5(sketch, canvas);
  }


  function sketch(p: p5) {

    function writeLines(x: number, y: number, lineHeight = 15) {
      let curY = y;
      return (text: string) => {
        p.text(text, x, curY);
        curY += lineHeight;
      };
    }

    p.setup = () => {
      p.createCanvas(400, 400);
    };

    p.draw = () => {

      p.background(220);

      p.strokeWeight(0);
      p.stroke('black');
      p.fill('black');

      const gameState = state?.gameState;
      if (!gameState) {
        p.text(`No game state yet`, 10, 20);
        return;
      }

      p.text(`State: ${state?.gameState?.GameMode}`, 10, 20);

      if (gameState.Players)
        Object.entries(gameState.Players).forEach(([key, player], index) => {

          p.strokeWeight(1);

          if (key === myPid) {
            p.stroke('blue');
          } else if (key === gameState?.BotState?.victim) {
            p.stroke('red');
          } else if (gameState?.BotState?.friends?.[key]) {
            p.stroke('green');
          }
          else {
            p.stroke('black'); // Set border color to black
          }

          p.fill('white');

          p.rect((player.x - 1) * 10, (player.y - 1) * 10, 10, 10);

          if (p.mouseX > (player.x - 1) * 10 && p.mouseX < player.x * 10 && p.mouseY > (player.y - 1) * 10 && p.mouseY < player.y * 10) {
            // Display a popup with the player's data

            const w = 120;
            const h = 90;

            const startX = p.mouseX + w > 400 ? p.mouseX - w : p.mouseX;
            const startY = p.mouseY + h > 400 ? p.mouseY - h : p.mouseY;

            p.fill(255);
            p.rect(startX, startY, w, h);
            p.fill(0);
            p.strokeWeight(0);
            p.stroke('black');

            const line = writeLines(startX + 10, startY + 20);

            line(`Player ${shortenCutMiddle(key, 9)}`);
            line(`Health: ${player.health}`);
            line(`Energy: ${player.energy}`);
            line(`XY: ${player.x}, ${player.y}`);

          }

        });


    }; // draw




  }

  function getMouseCell() {
    if (!p5Instance) return null;
    return {
      x: Math.floor(p5Instance.mouseX / 10),
      y: Math.floor(p5Instance.mouseY / 10),
    };
  }

  return { init, redraw, getMouseCell };
};
