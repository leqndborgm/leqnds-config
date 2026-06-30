import App from "ags/gtk4/app"
import { Astal, Gtk } from "ags/gtk4"
import { createState } from "ags"
import GLib from "gi://GLib"

const DAYS_SHORT = ["Mo", "Di", "Mi", "Do", "Fr", "Sa", "So"]
const MONTHS = [
  "Januar", "Februar", "März", "April", "Mai", "Juni",
  "Juli", "August", "September", "Oktober", "November", "Dezember",
]

function getDaysInMonth(year: number, month: number): number {
  const nm = month === 12 ? 1 : month + 1
  const ny = month === 12 ? year + 1 : year
  const next = GLib.DateTime.new_local(ny, nm, 1, 0, 0, 0)
  if (!next) return 30
  const last = next.add_days(-1)
  if (!last) return 30
  return last.get_day_of_month()
}

function getFirstWeekday(year: number, month: number): number {
  // Returns 0=Mon … 6=Sun (German week starts Monday)
  const dt = GLib.DateTime.new_local(year, month, 1, 0, 0, 0)
  if (!dt) return 0
  return dt.get_day_of_week() - 1
}

// Module-level timer so Clock and CalendarPopup share the same handle
let _hideTimer: ReturnType<typeof setTimeout> | null = null

export function showCalendar() {
  if (_hideTimer !== null) { clearTimeout(_hideTimer); _hideTimer = null }
  const win = App.get_window("calendar-popup")
  if (win && !win.visible) win.visible = true
}

export function hideCalendarDelayed() {
  if (_hideTimer !== null) return
  _hideTimer = setTimeout(() => {
    _hideTimer = null
    const win = App.get_window("calendar-popup")
    if (win) win.visible = false
  }, 450)
}

export function cancelHideCalendar() {
  if (_hideTimer !== null) { clearTimeout(_hideTimer); _hideTimer = null }
}

export default function CalendarPopup() {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor

  const now = GLib.DateTime.new_now_local()!
  const todayYear = now.get_year()
  const todayMonth = now.get_month() // 1-12
  const todayDay = now.get_day_of_month()

  const [year, setYear] = createState(todayYear)
  const [month, setMonth] = createState(todayMonth)
  const [monthLabel, setMonthLabel] = createState(
    `${MONTHS[todayMonth - 1]}  ${todayYear}`,
  )

  // Fixed 42-cell grid (max 6 rows × 7 cols)
  const cells = Array.from({ length: 42 }, () => {
    const [text, setText] = createState("")
    const [cls, setCls] = createState("cal-day empty")
    return { text, setText, cls, setCls }
  })

  function refreshGrid(y: number, m: number) {
    const numDays = getDaysInMonth(y, m)
    const start = getFirstWeekday(y, m)
    setMonthLabel(`${MONTHS[m - 1]}  ${y}`)
    cells.forEach((cell, i) => {
      const day = i - start + 1
      if (i < start || day > numDays || day < 1) {
        cell.setText("")
        cell.setCls("cal-day empty")
      } else {
        const isToday = day === todayDay && m === todayMonth && y === todayYear
        const col = i % 7
        const isWeekend = col === 5 || col === 6
        cell.setText(day.toString())
        cell.setCls(
          `cal-day${isToday ? " today" : ""}${isWeekend ? " weekend" : ""}`,
        )
      }
    })
  }

  refreshGrid(year(), month())

  function prevMonth() {
    const m = month(), y = year()
    const nm = m === 1 ? 12 : m - 1
    const ny = m === 1 ? y - 1 : y
    setMonth(nm); setYear(ny)
    refreshGrid(ny, nm)
  }

  function nextMonth() {
    const m = month(), y = year()
    const nm = m === 12 ? 1 : m + 1
    const ny = m === 12 ? y + 1 : y
    setMonth(nm); setYear(ny)
    refreshGrid(ny, nm)
  }

  return (
    <window
      name="calendar-popup"
      class="calendar-popup-window"
      anchor={TOP | LEFT | RIGHT}
      exclusivity={Astal.Exclusivity.NORMAL}
      application={App}
      visible={false}
      keymode={Astal.Keymode.ON_DEMAND}
      $={(self: any) => {
        const motion = new Gtk.EventControllerMotion()
        motion.connect("enter", cancelHideCalendar)
        motion.connect("leave", hideCalendarDelayed)
        self.add_controller(motion)
      }}
    >
      <box halign={Gtk.Align.CENTER} valign={Gtk.Align.START}>
        <box class="cal-panel" orientation={1} spacing={4}>

          {/* Month navigation */}
          <box class="cal-header" spacing={0}>
            <button class="cal-nav-btn" onClicked={prevMonth}>
              <label label="‹" />
            </button>
            <label
              class="cal-month-label"
              label={monthLabel}
              hexpand={true}
              halign={Gtk.Align.CENTER}
            />
            <button class="cal-nav-btn" onClicked={nextMonth}>
              <label label="›" />
            </button>
          </box>

          {/* Weekday headers */}
          <box class="cal-weekdays" spacing={0}>
            {DAYS_SHORT.map(d => (
              <label
                class={`cal-weekday${d === "Sa" || d === "So" ? " weekend" : ""}`}
                label={d}
                hexpand={true}
                halign={Gtk.Align.CENTER}
              />
            ))}
          </box>

          {/* Day grid — 6 rows */}
          {Array.from({ length: 6 }, (_, row) => (
            <box class="cal-row" spacing={0}>
              {cells.slice(row * 7, row * 7 + 7).map(cell => (
                <label
                  class={cell.cls}
                  label={cell.text}
                  hexpand={true}
                  halign={Gtk.Align.CENTER}
                />
              ))}
            </box>
          ))}

        </box>
      </box>
    </window>
  )
}
