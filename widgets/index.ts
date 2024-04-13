import { widget as BotWidget } from '~/widgets/botgame';
import { widget as UtilWidget } from '~/widgets/utils';
import { widget as ArenaWidget } from '~/widgets/arena';
import { widget as ConsoleWidget } from '~/widgets/console';

export const widgets = [BotWidget, UtilWidget, ArenaWidget, ConsoleWidget];

export function getWidgetDefinition(name: string) {
  return widgets.find(w => w.name === name);
}