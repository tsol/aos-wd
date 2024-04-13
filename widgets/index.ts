import { widget as BotWidget } from '~/widgets/botgame';
import { widget as UtilWidget } from '~/widgets/utils';
import { widget as ArenaWidget } from '~/widgets/arena';
import { widget as ConsoleWidget } from '~/widgets/console';
import { widget as IdeWidget } from '~/widgets/ide';

export const widgets = [BotWidget, UtilWidget, ArenaWidget, ConsoleWidget, IdeWidget];

export function getWidgetDefinition(name: string) {
  return widgets.find(w => w.name === name);
}