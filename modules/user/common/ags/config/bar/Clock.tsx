import GLib from "gi://GLib"
import { Gtk } from "ags/gtk4"
import { createState, onCleanup } from "ags"
import { showCalendar, hideCalendarDelayed, cancelHideCalendar } from "./CalendarPopup"

export default function Clock() {
  const [time, setTime] = createState(GLib.DateTime.new_now_local().format("%H:%M:%S") ?? "")
  const [date, setDate] = createState(GLib.DateTime.new_now_local().format("%A, %d. %b") ?? "")

  const timeId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
    setTime(GLib.DateTime.new_now_local().format("%H:%M:%S") ?? "")
    return GLib.SOURCE_CONTINUE
  })

  const dateId = GLib.timeout_add(GLib.PRIORITY_DEFAULT, 60000, () => {
    setDate(GLib.DateTime.new_now_local().format("%A, %d. %b") ?? "")
    return GLib.SOURCE_CONTINUE
  })

  onCleanup(() => {
    GLib.source_remove(timeId)
    GLib.source_remove(dateId)
  })

  return (
    <box class="clock-box" orientation={1 /* VERTICAL */} halign={2 /* CENTER */} spacing={0}>
      <label class="clock-time" label={time} />
      <label
        class="clock-date"
        label={date}
        $={(self: any) => {
          const motion = new Gtk.EventControllerMotion()
          motion.connect("enter", showCalendar)
          motion.connect("leave", hideCalendarDelayed)
          self.add_controller(motion)
        }}
      />
    </box>
  )
}
