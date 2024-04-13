import { widget as BotWidget } from '~/widgets/botgame';
import { widget as UtilWidget } from '~/widgets/utils';
import { widget as ArenaWidget } from '~/widgets/arena';
import { widget as ConsoleWidget } from '~/widgets/console';
import { widget as IdeWidget } from '~/widgets/ide';
import type { StoredSnippet, StoredWidget } from '~/store/persist';

export const widgets = [BotWidget, UtilWidget, ArenaWidget, ConsoleWidget, IdeWidget];

export function getWidgetDefinition(name: string) {
  return widgets.find(w => w.name === name);
}

/*
export type StoredSnippet = {
  name: string;
  code: string;
}

export type StoredWidget = {
  name: string;
  column?: number;
  colWidth?: number;
  snippets?: StoredSnippet[];
}
*/

export function createWidget(name: string): StoredWidget | null {
  const widget = getWidgetDefinition(name);
  if (!widget) return null;

  return {
    name,
    column: 0,
    colWidth: 12,
    snippets: widget.snippets.map(snippet => ({
      name: snippet.name,
      data: snippet.data,
      tags: snippet.tags,
      pid: snippet.pid,
    } as StoredSnippet))
  };
  
}