{ name, mkSoftware, ... }:
mkSoftware name (
  { vdir-calendar-notifier, ... }:
  {
    hm.services.vdir-calendar-notifier = {
      inherit (vdir-calendar-notifier) enable;
      calendarRoot = "calendars";
      defaultTrigger = "-PT15M";
      defaultAllDayTrigger = "PT9H";
      icon = "stock_appointment-reminder";
      sound = "complete";
      urgency = "critical";
    };
  }
)
